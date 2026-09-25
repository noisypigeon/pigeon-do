locals {
  # Secrets: read from this domain's own repo-root ".env" file. pigeon.dev
  # no longer manages any DigitalOcean resources directly (its DigitalOcean
  # side was decommissioned — see docs/adr/0008-scaleway-provider.md) — this
  # domain's remaining leaves are Cloudflare-only, so unlike
  # digitalocean/root.hcl there is no provider "digitalocean"/"scaleway"
  # here. DIGITALOCEAN_* keys below exist solely to authenticate to the
  # shared state backend (noisypigeon.com's bucket), not to manage any of
  # pigeon.dev's own DigitalOcean resources.
  root_env_path = "${get_repo_root()}/pigeon.dev.env"

  root_secrets = { for pair in [
    for line in split("\n", fileexists(local.root_env_path) ? file(local.root_env_path) : "") :
    regex("^([^=]+)=(.*)$", trimspace(line))
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
    && can(regex("^([^=]+)=(.*)$", trimspace(line)))
  ] : trimspace(pair[0]) => trimspace(pair[1]) }

  secrets = local.root_secrets
}

generate "cloudflare_ids" {
  path      = "cloudflare_ids_generated.tf"
  if_exists = "overwrite"
  contents  = <<EOF
locals {
  cloudflare_account_id         = "${get_env("CLOUDFLARE_ACCOUNT_ID", lookup(local.secrets, "CLOUDFLARE_ACCOUNT_ID", ""))}"
  cloudflare_pigeon_dev_zone_id = "${get_env("CLOUDFLARE_PIGEON_DEV_ZONE_ID", lookup(local.secrets, "CLOUDFLARE_PIGEON_DEV_ZONE_ID", ""))}"
}
EOF
}

generate "provider" {
  path      = "provider_generated.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "cloudflare" {
  api_token         = "${get_env("CLOUDFLARE_TOKEN", lookup(local.secrets, "CLOUDFLARE_TOKEN", ""))}"
}
EOF
}

# Configure backend to use the shared Spaces bucket (noisypigeon.com's — see
# docs/adr/0008-scaleway-provider.md). pigeon.dev.env's DIGITALOCEAN_* keys
# below must be set to noisypigeon.com's real bucket/Spaces credentials.
remote_state {
  backend = "s3"

  config = {
    endpoint                    = "https://tor1.digitaloceanspaces.com"
    region                      = "tor1"
    bucket                      = lookup(local.secrets, "DIGITALOCEAN_TERRAFORM_STATE_BUCKET", "")
    key                         = "${path_relative_to_include()}/terraform.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true

    access_key = get_env("DIGITALOCEAN_SPACES_ACCESS_ID", lookup(local.secrets, "DIGITALOCEAN_SPACES_ACCESS_ID", ""))
    secret_key = get_env("DIGITALOCEAN_SPACES_SECRET_KEY", lookup(local.secrets, "DIGITALOCEAN_SPACES_SECRET_KEY", ""))
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}
