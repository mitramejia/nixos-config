import assert from "node:assert/strict"
import { spawn } from "node:child_process"
import { cpSync, mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const [binary, tempParent] = process.argv.slice(2)
assert(binary && tempParent, "Usage: node plugins.acceptance.mjs <patched-opencode> <temp-parent>")
const root = mkdtempSync(path.join(tempParent, "plugin-acceptance-"))
const config = path.join(root, "config/opencode")
const directory = path.join(root, "project")
mkdirSync(config, { recursive: true })
mkdirSync(directory)
cpSync(fileURLToPath(new URL("./plugins", import.meta.url)), path.join(config, "plugins"), { recursive: true })
writeFileSync(
  path.join(config, "opencode.json"),
  JSON.stringify({
    plugins: [],
    mcp: { servers: { browserstack: { type: "local", command: ["false"], environment: { KEEP: "fixture" } } } },
  }),
)
writeFileSync(path.join(config, "cli.json"), JSON.stringify({ plugins: [] }))

// Do not inherit credentials, server URLs, or a real Herdr pane. Own an isolated
// stdio server lease; closing its stdin stops only this test's child process.
const env = {
  PATH: process.env.PATH,
  HOME: path.join(root, "home"),
  TMPDIR: root,
  XDG_CONFIG_HOME: path.join(root, "config"),
  XDG_DATA_HOME: path.join(root, "data"),
  XDG_STATE_HOME: path.join(root, "state"),
  XDG_CACHE_HOME: path.join(root, "cache"),
  OPENCODE_CONFIG_DIR: config,
  OPENCODE_DISABLE_MODELS_FETCH: "true",
  OPENCODE_PASSWORD: "fixture-private",
}
async function withServer(extra, check) {
  const child = spawn(binary, ["serve", "--stdio", "--hostname", "127.0.0.1", "--port", "0"], {
    cwd: directory,
    env: { ...env, ...extra },
    stdio: ["pipe", "pipe", "pipe"],
  })
  let stderr = ""
  child.stderr.on("data", (chunk) => {
    stderr += chunk
  })
  const exited = new Promise((resolve) => child.once("exit", resolve))
  try {
    const url = await new Promise((resolve, reject) => {
      let text = ""
      const timer = setTimeout(() => reject(new Error("Private server readiness timeout: " + stderr)), 30000)
      child.once("exit", () => {
        clearTimeout(timer)
        reject(new Error("Private server exited: " + stderr))
      })
      child.stdout.on("data", (chunk) => {
        text += chunk
        for (const line of text.split("\n")) {
          try {
            const ready = JSON.parse(line)
            if (!ready.url) continue
            clearTimeout(timer)
            resolve(ready.url)
          } catch {}
        }
      })
    })
    const api = async (route) => {
      const response = await fetch(`${url}/api/${route}?location[directory]=${encodeURIComponent(directory)}`, {
        headers: { Authorization: "Basic " + Buffer.from("opencode:fixture-private").toString("base64") },
        signal: AbortSignal.timeout(30000),
      })
      if (!response.ok) throw new Error(await response.text())
      return (await response.json()).data
    }
    await check(api)
  } finally {
    child.stdin.end()
    const timer = setTimeout(() => child.kill("SIGTERM"), 5000)
    await exited
    clearTimeout(timer)
  }
}
try {
  await withServer({}, async (api) => {
    let missing
    for (let attempt = 0; attempt < 100 && !missing; attempt++) {
      missing = (await api("mcp")).find((server) => server.name === "browserstack")
      if (!missing) await new Promise((resolve) => setTimeout(resolve, 100))
    }
    assert.equal(missing?.status.status, "disabled")
    const plugins = await api("plugin")
    for (const id of ["local.rtk", "local.browserstack-env"]) {
      assert.equal(plugins.find((plugin) => plugin.id === id)?.state.status, "active", JSON.stringify(plugins))
    }
    assert(!plugins.some((plugin) => plugin.source.path?.endsWith("herdr-agent-state.js")))
  })
  await withServer({ BROWSERSTACK_USERNAME: "fixture", BROWSERSTACK_ACCESS_KEY: "fixture" }, async (api) => {
    let both
    for (let attempt = 0; attempt < 100 && !both; attempt++) {
      both = (await api("mcp")).find((server) => server.name === "browserstack")
      if (!both) await new Promise((resolve) => setTimeout(resolve, 100))
    }
    // The deliberately non-MCP `false` command must now be attempted, not gated.
    assert.notEqual(both?.status.status, "disabled")
    assert(both)
  })
  console.log("PASS: real V2 plugin setup (RTK/BrowserStack), BrowserStack missing/both credentials transform")
  console.log(
    "Herdr TUI host is not instantiated by this headless acceptance; see socket/registration regression tests.",
  )
} finally {
  rmSync(root, { recursive: true, force: true })
}
