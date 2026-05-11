# GetBored Core — Project Instructions

## What this repo owns

Shared contracts, policy engine, identifiers, and CloudKit constants used across iOS and macOS filter implementations.

## Agent routing

Contract changes touch shared types across platforms. Route via these rules:

| Path glob | Agent | Model |
|---|---|---|
| `Sources/**` (policy, identifiers, CloudKit types) | mac-filter-engineer or ios-filter-engineer | sonnet |
| `tests/**`, `Package.swift` | same as touched sources | sonnet |

When a contract change spans both iOS and macOS filters, request an Opus plan first that decomposes work per filter repo.

## Commit message rules

Use **Conventional Commits** format:

```
type(scope): short description

Refs: tushru2004/GetBored#N
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `perf`

**Scopes:** `core`, `policy`, `identifiers`, `cloudkit`

**Footer:** Always include `Refs:` or `Fixes:` referencing an issue in the monorepo project.

**Rules:**
- Never add `Co-Authored-By` lines
- Only commit when explicitly asked by the user

## Cross-cutting

For architecture decisions affecting multiple repos, see `tushru2004/getbored` CLAUDE.md.
