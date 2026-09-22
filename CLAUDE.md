# CLAUDE.md

`pigeon-do` is a infrastructure as code configuration repo (Terragrunt + Terraform).

## ADRs govern this project

Before making architectural or interface changes, read the ADRs in `docs/adr/` and keep new work consistent with their decisions. If a change would contradict an existing ADR, flag it rather than silently diverging — prefer writing a new ADR (or updating an existing one's Status) over undocumented drift.

- `docs/adr/0001-terragrunt-terraform-bootstrap.md` — The initial bootstrapping of this repository.

## Commands

- `mise run fmt` — Terragrunt HCL formatting.
- `mise run fmt-check` — Read-only Terragrunt HCL formatting.
- `mise run plan` — Terragrunt Plan
- `mise run apply` / Terragrunt Apply
