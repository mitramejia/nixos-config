import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "local.browserstack-env",
  async setup(ctx) {
    if (process.env.BROWSERSTACK_USERNAME && process.env.BROWSERSTACK_ACCESS_KEY) return
    await ctx.mcp.transform((editor) => {
      editor.update("browserstack", (server) => {
        server.disabled = true
      })
    })
  },
})
