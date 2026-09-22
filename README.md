# pigeon-do

Infrastructure-as-Code using Terragrunt to manage `pigeon.dev`'s resources in DigitalOcean and Cloudflare.

## Getting started

1. Install the pinned toolchain: `mise install`.
2. `cp .env.example .env` and fill in real values (Cloudflare API token, DigitalOcean token, Spaces access key/secret, Terraform state bucket name). `.env` is git-ignored and must never be committed.
3. `mise run fmt` / `mise run fmt-check` format and check `root.hcl` and `*.tf` files.
4. `mise run plan` / `mise run apply` wrap `terragrunt run --all -- plan`/`apply`.

`root.hcl` is the shared Terragrunt configuration (provider setup, remote state, env inheritance) included by every stack. See `docs/adr/0001-terragrunt-terraform-bootstrap.md` for the design decisions behind it. Modules and leaf stacks don't exist yet — that's deferred to a follow-up ADR.
