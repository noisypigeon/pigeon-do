locals {
  # Secrets: read from this provider's own ".env" file (cloudflare/.env),
  # found the same way every leaf finds this root.hcl itself (nearest
  # ancestor). Backend credentials (DIGITALOCEAN_SPACES_*/TERRAFORM_STATE_BUCKET)
  # are duplicated here from digitalocean/.env, since all three providers
  # share the same state bucket — see docs/adr/0009-per-provider-root-hcl.md.
  # This is only for noisypigeon.com's Cloudflare leaves — pigeon.dev's
  # Cloudflare leaves are unaffected, they still use pigeon.dev.hcl.
  root_env_path = find_in_parent_folders(".env", "")

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
  cloudflare_noisypigeon_com_zone_id = "${get_env("CLOUDFLARE_NOISYPIGEON_COM_ZONE_ID", lookup(local.secrets, "CLOUDFLARE_NOISYPIGEON_COM_ZONE_ID", ""))}"
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

# Configure backend to use the shared Spaces bucket (same one
# digitalocean/root.hcl uses).
remote_state {
  backend = "s3"

  config = {
    endpoint = "https://tor1.digitaloceanspaces.com"
    region   = "tor1"
    bucket   = lookup(local.secrets, "DIGITALOCEAN_TERRAFORM_STATE_BUCKET", "")
    # Prefixed with "cloudflare" so leaves' state keys are unchanged now
    # that this file lives inside cloudflare/ instead of the repo root —
    # see docs/adr/0009-per-provider-root-hcl.md.
    key                         = "cloudflare/${path_relative_to_include()}/terraform.tfstate"
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
