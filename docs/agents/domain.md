# Domain Docs

How engineering skills should consume this repo's domain documentation.

## Before exploring, read these

- `CONTEXT.md` at the repo root, or `CONTEXT-MAP.md` if it exists
- `docs/adr/`
- `src/<context>/docs/adr/` for a relevant context, when present

If any are absent, proceed silently. `/domain-modeling` creates them lazily when terms or decisions are resolved.

## File structure

This is a single-context repository:

```
/
├── CONTEXT.md
└── docs/adr/
```

## Use the glossary's vocabulary

Use terms defined in `CONTEXT.md` in issues, refactor proposals, hypotheses, and tests. If a needed concept is absent, reconsider the term or note the gap for `/domain-modeling`.

## Flag ADR conflicts

Surface a contradiction explicitly rather than silently overriding it.
