import { Plugin } from "@opencode/plugin"
import { execFile } from "node:child_process"
import { promisify } from "node:util"

const exec = promisify(execFile)

// Requires RTK >= 0.23. Delegate all rewrite rules to its registry.
export default Plugin.define({
  id: "local.rtk",
  async setup(ctx) {
    await ctx.tool.hook("execute.before", async (event) => {
      if (!["shell", "bash"].includes(event.tool.toLowerCase())) return
      if (!event.input || typeof event.input !== "object") return
      const input = event.input as { command?: unknown }
      if (typeof input.command !== "string" || !input.command) return
      let stdout: string
      try {
        // execFile passes the command as one argument, never as shell source.
        stdout = (await exec("rtk", ["rewrite", input.command], { timeout: 5000 })).stdout
      } catch (error) {
        // RTK 0.41 uses exit 3 for ask+rewrite. OpenCode still owns permission
        // evaluation; 1 (no match), 2 (deny), and genuine failures pass through.
        const result = error as { code?: unknown; stdout?: unknown }
        if (result.code !== 3 || typeof result.stdout !== "string") return
        stdout = result.stdout
      }
      const rewritten = stdout.trim()
      if (rewritten) input.command = rewritten
    })
  },
})
