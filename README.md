# pigeon-do

Infrastructure-as-Code using Terragrunt to manage resources in DigitalOcean and Cloudflare, across multiple accounts/domains (`pigeon.dev`, `noisypigeon.com`).

## Getting started

1. Install the pinned toolchain: `mise install`.
2. For each account you need (e.g. `pigeon.dev/`, `noisypigeon.com/`): `cp <account>/.env.example <account>/.env` and fill in that account's real values (DigitalOcean token, Spaces access key/secret, Terraform state bucket name, plus Cloudflare credentials where applicable). Each `.env` is git-ignored and must never be committed.
3. `mise run fmt` / `mise run fmt-check` format and check every `root.hcl`/`common.hcl` and `*.tf` file.
4. `mise run plan` / `mise run apply` wrap `terragrunt run --all -- plan`/`apply`, walking every account's leaves in one invocation.

Each top-level directory (`pigeon.dev/`, `noisypigeon.com/`) is a self-contained **root directory**: its own `root.hcl` (provider setup, remote state, env inheritance), `.env`/`.env.example`, and `env.tf`, isolated from every other account. The repo-root `common.hcl` holds the few things that aren't account-specific (e.g. the `pigeon-tf` module checkout path). See `docs/adr/0001-terragrunt-terraform-bootstrap.md` and `docs/adr/0007-multiple-root-directories.md` for the design decisions behind this.
