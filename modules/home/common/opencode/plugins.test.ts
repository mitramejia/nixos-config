import { test, expect, mock } from "bun:test"
import { chmodSync, mkdtempSync, rmSync, writeFileSync } from "node:fs"
import net from "node:net"
import path from "node:path"

// Only the host registration surface is mocked; RTK subprocesses and the
// newline-delimited Herdr socket transport below are real.
mock.module("@opencode/plugin", () => ({ Plugin: { define: (definition: unknown) => definition } }))
mock.module("@opencode/plugin/tui", () => ({ Plugin: { define: (definition: unknown) => definition } }))
mock.module("solid-js", () => ({ createEffect: (effect: () => void) => effect() }))
const rtk = (await import("./plugins/rtk")).default
const browserstack = (await import("./plugins/browserstack-env")).default
const herdr = (await import("./plugins/herdr-agent-state/tui")).default

test("RTK delegates shell rewrites, and leaves non-shell/empty/no-match commands alone", async () => {
  let hook: any
  await rtk.setup({
    tool: {
      hook: async (name: string, callback: any) => {
        expect(name).toBe("execute.before")
        hook = callback
      },
    },
  } as any)
  const event = { tool: "shell", input: { command: "git status", description: "keep" } }
  await hook(event)
  expect(event.input).toEqual({ command: "rtk git status", description: "keep" })
  for (const event of [
    { tool: "read", input: { command: "git status" } },
    { tool: "shell", input: { command: "" } },
    { tool: "shell", input: { command: "printf hello" } },
    { tool: "shell", input: null },
  ]) {
    const before = structuredClone(event)
    await hook(event)
    expect(event).toEqual(before)
  }
})

test("RTK failures (including nonzero exit with stdout) pass through", async () => {
  const directory = mkdtempSync("/tmp/rtk-plugin-")
  const oldPath = process.env.PATH
  try {
    let hook: any
    await rtk.setup({
      tool: {
        hook: async (_: string, callback: any) => {
          hook = callback
        },
      },
    } as any)
    const executable = path.join(directory, "rtk")
    writeFileSync(executable, "#!/bin/sh\nprintf 'must-not-use-this'\nexit 1\n")
    chmodSync(executable, 0o755)
    process.env.PATH = directory
    const event = { tool: "bash", input: { command: "git status" } }
    await hook(event)
    expect(event.input.command).toBe("git status")
    rmSync(executable)
    await hook(event)
    expect(event.input.command).toBe("git status")
  } finally {
    process.env.PATH = oldPath
    rmSync(directory, { recursive: true, force: true })
  }
})

test("BrowserStack needs both credentials; transform changes only disabled", async () => {
  const username = process.env.BROWSERSTACK_USERNAME
  const key = process.env.BROWSERSTACK_ACCESS_KEY
  try {
    for (const [user, access] of [
      [undefined, undefined],
      ["fixture", undefined],
      [undefined, "fixture"],
      ["fixture", "fixture"],
    ]) {
      if (user) process.env.BROWSERSTACK_USERNAME = user
      else delete process.env.BROWSERSTACK_USERNAME
      if (access) process.env.BROWSERSTACK_ACCESS_KEY = access
      else delete process.env.BROWSERSTACK_ACCESS_KEY
      const server = { type: "local", command: ["custom"], environment: { KEEP: "yes" }, disabled: false }
      const other = { type: "remote", url: "https://fixture.invalid" }
      let registered = false
      await browserstack.setup({
        mcp: {
          transform: async (callback: any) => {
            registered = true
            callback({
              update: (name: string, update: any) => {
                expect(name).toBe("browserstack")
                update(server)
              },
            })
            // A replayable transform must not add or reset anything else.
            callback({ update: (_: string, update: any) => update(server) })
          },
        },
      } as any)
      expect(registered).toBe(!(user && access))
      expect(server).toEqual({
        type: "local",
        command: ["custom"],
        environment: { KEEP: "yes" },
        disabled: !(user && access),
      })
      expect(other).toEqual({ type: "remote", url: "https://fixture.invalid" })
    }
  } finally {
    if (username === undefined) delete process.env.BROWSERSTACK_USERNAME
    else process.env.BROWSERSTACK_USERNAME = username
    if (key === undefined) delete process.env.BROWSERSTACK_ACCESS_KEY
    else process.env.BROWSERSTACK_ACCESS_KEY = key
  }
})

function terminal(sessionID: string) {
  let route: any = { type: "session", sessionID }
  let listener: any
  let render: any
  const sessions = new Map<string, any>([[sessionID, { id: sessionID }]])
  let stopped = false
  let unregistered = false
  const ctx = {
    data: {
      listen(callback: any) {
        listener = callback
        return () => {
          stopped = true
        }
      },
      session: {
        get: (id: string) => sessions.get(id),
        root: (id: string): string =>
          sessions.get(id)?.parentID ? ctx.data.session.root(sessions.get(id).parentID) : id,
        family: (id: string) => [id],
        status: () => "idle",
        permission: { list: () => [] },
        form: { list: () => [] },
      },
    },
    ui: {
      router: { current: () => route },
      slot(claim: any) {
        expect(claim.append).toBe("app")
        render = claim.render
        render()
        return () => {
          unregistered = true
        }
      },
    },
  }
  return {
    ctx,
    event(type: string, data: any) {
      if (type === "session.created") sessions.set(data.sessionID, { id: data.sessionID, ...data })
      listener({ details: { type, data } })
    },
    select(id: string) {
      route = { type: "session", sessionID: id }
      render()
    },
    cleanup: () => ({ stopped, unregistered }),
  }
}

test("Herdr stays inert outside a Herdr terminal", () => {
  const previous = process.env.HERDR_ENV
  process.env.HERDR_ENV = "0"
  try {
    expect(herdr.setup({} as any)).toBeUndefined()
  } finally {
    if (previous === undefined) delete process.env.HERDR_ENV
    else process.env.HERDR_ENV = previous
  }
})

test("Herdr is pane-local: root/child states, other-root exclusion, socket protocol and cleanup", async () => {
  const directory = mkdtempSync("/tmp/herdr-plugin-")
  const socketPath = path.join(directory, "socket")
  const env = {
    HERDR_ENV: process.env.HERDR_ENV,
    HERDR_SOCKET_PATH: process.env.HERDR_SOCKET_PATH,
    HERDR_PANE_ID: process.env.HERDR_PANE_ID,
  }
  const requests: any[] = []
  let holdResponse = false
  const server = net.createServer((socket) => {
    let text = ""
    socket.on("data", (chunk) => {
      text += chunk
      if (!text.includes("\n")) return
      requests.push(JSON.parse(text.trim()))
      if (!holdResponse) socket.end("{}\n")
    })
  })
  await new Promise<void>((resolve) => server.listen(socketPath, resolve))
  const wait = async (count: number) => {
    for (let attempt = 0; requests.length < count && attempt < 200; attempt++) await Bun.sleep(5)
    expect(requests.length).toBe(count)
  }
  let disposeA: any
  let disposeB: any
  try {
    process.env.HERDR_ENV = "1"
    process.env.HERDR_SOCKET_PATH = socketPath
    process.env.HERDR_PANE_ID = "pane-a"
    const a = terminal("root-a")
    disposeA = herdr.setup(a.ctx as any)
    process.env.HERDR_PANE_ID = "pane-b"
    const b = terminal("root-b")
    disposeB = herdr.setup(b.ctx as any)
    await wait(4)
    const emit = (type: string, data: any) => {
      a.event(type, data)
      b.event(type, data)
    }
    emit("session.created", { sessionID: "root-a" })
    await wait(5)
    expect(requests[4].params.session_start_source).toBe("new")
    emit("session.execution.started", { sessionID: "root-a" })
    await wait(6)
    emit("session.created", { sessionID: "child-a", parentID: "root-a" })
    a.select("child-a")
    emit("permission.asked", { sessionID: "child-a", id: "per-fixture" })
    await wait(7)
    emit("session.execution.succeeded", { sessionID: "root-a" })
    emit("session.execution.failed", { sessionID: "unrelated" })
    await Bun.sleep(30)
    expect(requests.length).toBe(7)
    emit("permission.replied", { sessionID: "child-a", requestID: "per-fixture" })
    await wait(8)
    emit("form.created", { form: { sessionID: "child-a", id: "form-fixture" } })
    await wait(9)
    emit("form.cancelled", { sessionID: "child-a", id: "form-fixture" })
    await wait(10)
    emit("session.execution.succeeded", { sessionID: "root-a" })
    await wait(11)
    emit("session.execution.failed", { sessionID: "root-a" })
    await wait(12)
    emit("session.execution.interrupted", { sessionID: "root-a" })
    await wait(13)
    expect(requests.slice(5).map((r) => r.params.state)).toEqual([
      "working",
      "blocked",
      "working",
      "blocked",
      "working",
      "idle",
      "blocked",
      "idle",
    ])
    for (const request of requests.slice(4)) {
      expect(request.params.pane_id).toBe("pane-a")
      expect(request.params.agent_session_id).toBe("root-a")
      expect(request.params.source).toBe("herdr:opencode")
      expect(request.params.agent).toBe("opencode")
    }
    const sequence = requests.filter((r) => r.params.pane_id === "pane-a").map((r) => r.params.seq)
    expect(sequence.every((seq, i) => i === 0 || seq > sequence[i - 1])).toBe(true)
    // Route selection, rather than unrelated session.created, owns new roots.
    a.select("unhydrated-child")
    await Bun.sleep(30)
    expect(requests.length).toBe(13)
    emit("session.created", { sessionID: "new-root" })
    a.select("new-root")
    await wait(15)
    expect(requests[13].params).toMatchObject({ agent_session_id: "new-root", session_start_source: "new" })
    // Dispose while a real socket is awaiting its response, not only after
    // queued requests have settled. server.close below must still complete.
    holdResponse = true
    emit("session.execution.started", { sessionID: "new-root" })
    await wait(16)
    disposeA()
    disposeB()
    expect(a.cleanup()).toEqual({ stopped: true, unregistered: true })
    expect(b.cleanup()).toEqual({ stopped: true, unregistered: true })
    emit("session.execution.started", { sessionID: "new-root" })
    await Bun.sleep(30)
    expect(requests.length).toBe(16)
  } finally {
    disposeA?.()
    disposeB?.()
    for (const [name, value] of Object.entries(env)) {
      if (value === undefined) delete process.env[name]
      else process.env[name] = value
    }
    await new Promise<void>((resolve) => server.close(() => resolve()))
    rmSync(directory, { recursive: true, force: true })
  }
})
