import assert from "node:assert/strict"
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from "node:fs"
import { tmpdir } from "node:os"
import path from "node:path"
import { pathToFileURL } from "node:url"
import { test } from "bun:test"
import { Host } from "./packages/plugin/src/host"
import { resolveModule } from "./packages/util/src/runtime/import.bun"

test("real Bun resolver supports VimCode's TUI-only exports", () => {
  const root = mkdtempSync(path.join(tmpdir(), "opencode-vimcode-"))
  const directory = path.join(root, "node_modules/vimcode")
  mkdirSync(path.join(directory, "src"), { recursive: true })
  writeFileSync(path.join(directory, "package.json"), JSON.stringify({
    name: "vimcode", type: "module", exports: { "./tui": "./src/index.ts" },
  }))
  writeFileSync(path.join(directory, "src/index.ts"), 'throw new Error("must not execute")')
  try {
    assert.deepEqual(Host.resolve({ name: "vimcode", directory }), {
      server: undefined, tui: pathToFileURL(path.join(directory, "src/index.ts")).href, rpc: undefined,
    })
  } finally {
    rmSync(root, { recursive: true, force: true })
  }
})

test("resolver propagates genuine failures unchanged", () => {
  const original = Bun.resolveSync
  for (const error of [new SyntaxError("invalid package"), { name: "ResolveMessage", message: "invalid package.json" }]) {
    Bun.resolveSync = () => { throw error }
    try {
      assert.throws(() => resolveModule("vimcode/server", "/tmp"), (caught) => caught === error)
      assert.throws(() => Host.resolve({ name: "vimcode", directory: "/tmp" }), (caught) => caught === error)
    } finally {
      Bun.resolveSync = original
    }
  }
})

test("missing ResolveMessage without a code is normalized", () => {
  const original = Bun.resolveSync
  Bun.resolveSync = (specifier, directory) => {
    throw { name: "ResolveMessage", message: `Cannot find module '${specifier}' from '${directory}'` }
  }
  try {
    assert.deepEqual(Host.resolve({ name: "vimcode", directory: "/tmp" }), {
      server: undefined, tui: undefined, rpc: undefined,
    })
  } finally {
    Bun.resolveSync = original
  }
})
