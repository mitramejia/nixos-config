import { Plugin } from "@opencode/plugin/tui"
import { createEffect } from "solid-js"
import net from "node:net"

// Deliberately terminal-local. Never report a server process's pane environment.
// This path is owned by nix-config, not Herdr's V1 integration installer.
export default Plugin.define({
  id: "local.herdr-agent-state",
  setup(ctx) {
    const paneID = process.env.HERDR_PANE_ID
    const socketPath = process.env.HERDR_SOCKET_PATH
    if (process.env.HERDR_ENV !== "1" || !paneID || !socketPath) return

    const endpoint = process.platform === "win32" ? `\\\\.\\pipe\\${socketPath}` : socketPath
    let seq = Date.now() * 1000
    let disposed = false
    let chain = Promise.resolve()
    let selected: string | undefined
    let lastState: string | undefined
    const sockets = new Set<net.Socket>()
    const parents = new Map<string, string>()
    const created = new Set<string>()
    const pending = new Map<string, string>()

    function request(method: string, params: Record<string, unknown>) {
      chain = chain
        .then(
          () =>
            new Promise<void>((resolve) => {
              if (disposed) return resolve()
              const client = net.createConnection(endpoint, () => {
                client.write(
                  JSON.stringify({
                    id: `herdr:opencode:${Date.now()}:${++seq}`,
                    method,
                    params: { pane_id: paneID, source: "herdr:opencode", agent: "opencode", seq, ...params },
                  }) + "\n",
                )
              })
              sockets.add(client)
              const finish = () => {
                sockets.delete(client)
                client.destroy()
                resolve()
              }
              client.setTimeout(500, finish)
              client.on("data", finish)
              client.on("error", finish)
              client.on("end", finish)
              client.on("close", finish)
            }),
        )
        .catch(() => {})
    }

    function root(sessionID: string): string {
      const seen = new Set<string>()
      while (!seen.has(sessionID)) {
        seen.add(sessionID)
        const parent = parents.get(sessionID) ?? ctx.data.session.get(sessionID)?.parentID
        if (!parent) break
        sessionID = parent
      }
      return ctx.data.session.root(sessionID)
    }

    function report(state: string) {
      if (!selected || disposed) return
      if ([...pending.values()].some((sessionID) => root(sessionID) === selected)) state = "blocked"
      if (lastState === state) return
      lastState = state
      request("pane.report_agent", { state, agent_session_id: selected })
    }

    function select() {
      const route = ctx.ui.router.current()
      // An unhydrated child can look like a root. Wait for cached metadata
      // rather than attaching that child ID to the pane during navigation.
      const candidate =
        route.type === "session" && ctx.data.session.get(route.sessionID) ? root(route.sessionID) : undefined
      const next = candidate && ctx.data.session.get(candidate) ? candidate : undefined
      if (next === selected) return
      selected = next
      lastState = undefined
      if (!next) return
      request("pane.report_agent_session", {
        agent_session_id: next,
        ...(created.delete(next) ? { session_start_source: "new" } : {}),
      })
      for (const sessionID of ctx.data.session.family(next)) {
        for (const permission of ctx.data.session.permission.list(sessionID) ?? []) {
          pending.set(`permission:${permission.id}`, sessionID)
        }
        for (const form of ctx.data.session.form.list(sessionID) ?? []) {
          pending.set(`form:${form.id}`, sessionID)
        }
      }
      report(ctx.data.session.status(next) === "running" ? "working" : "idle")
    }

    const stop = ctx.data.listen(({ details: event }) => {
      if (disposed) return
      if (event.type === "session.created") {
        if (event.data.parentID) parents.set(event.data.sessionID, event.data.parentID)
        else created.add(event.data.sessionID)
      }
      select()
      if (
        event.type === "session.created" &&
        !event.data.parentID &&
        event.data.sessionID === selected &&
        created.delete(selected)
      ) {
        request("pane.report_agent_session", { agent_session_id: selected, session_start_source: "new" })
      }
      const sessionID =
        event.type === "form.created"
          ? event.data.form.sessionID
          : "sessionID" in event.data
            ? event.data.sessionID
            : undefined
      if (typeof sessionID !== "string" || !selected || root(sessionID) !== selected) return
      switch (event.type) {
        case "permission.asked":
          pending.set(`permission:${event.data.id}`, sessionID)
          report("blocked")
          break
        case "form.created":
          pending.set(`form:${event.data.form.id}`, sessionID)
          report("blocked")
          break
        case "permission.replied":
          pending.delete(`permission:${event.data.requestID}`)
          report("working")
          break
        case "form.replied":
        case "form.cancelled":
          pending.delete(`form:${event.data.id}`)
          report("working")
          break
        case "session.execution.started":
        case "session.inbox.enqueued":
          if (sessionID === selected) report("working")
          break
        case "session.execution.succeeded":
        case "session.execution.interrupted":
          if (sessionID === selected) report("idle")
          break
        case "session.execution.failed":
          if (sessionID === selected) report("blocked")
          break
      }
    })
    // A route change is client-local, not a server event. Observe it in a
    // documented app slot so even a resumed, already-idle session is reported.
    const unregister = ctx.ui.slot({
      append: "app",
      render: () => {
        createEffect(select)
        return null
      },
    })
    select()
    return () => {
      disposed = true
      stop()
      unregister()
      for (const socket of sockets) socket.destroy()
      sockets.clear()
      pending.clear()
      parents.clear()
      created.clear()
    }
  },
})
