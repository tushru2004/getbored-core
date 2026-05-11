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

## Commit rules
See `~/.claude/skills/commit-rules/` — invoked at commit time, not loaded every message.

## Cross-cutting

For architecture decisions affecting multiple repos, see `tushru2004/getbored` CLAUDE.md.
