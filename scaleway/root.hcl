locals {
  # Secrets: read from this provider's own ".env" file (scaleway/.env),
  # found the same way every leaf finds this root.hcl itself (nearest
  # ancestor). Backend credentials (DIGITALOCEAN_SPACES_*/TERRAFORM_STATE_BUCKET)
  # are duplicated here from digitalocean/.env, since all three providers
  # share the same state bucket — see docs/adr/0009-per-provider-root-hcl.md.
  root_env_path = find_in_parent_folders(".env", "")

  root_secrets = { for pair in [
    for line in split("\n", fileexists(local.root_env_path) ? file(local.root_env_path) : "") :
    regex("^([^=]+)=(.*)$", trimspace(line))
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
    && can(regex("^([^=]+)=(.*)$", trimspace(line)))
  ] : trimspace(pair[0]) => trimspace(pair[1]) }

  secrets = local.root_secrets
}

generate "provider" {
  path      = "provider_generated.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.0"
    }
  }
}

provider "scaleway" {
  access_key      = "${get_env("SCALEWAY_ACCESS_KEY", lookup(local.secrets, "SCALEWAY_ACCESS_KEY", ""))}"
  secret_key      = "${get_env("SCALEWAY_SECRET_KEY", lookup(local.secrets, "SCALEWAY_SECRET_KEY", ""))}"
  organization_id = "${get_env("SCALEWAY_ORGANIZATION_ID", lookup(local.secrets, "SCALEWAY_ORGANIZATION_ID", ""))}"
}
EOF
}

# Configure backend to use the shared Spaces bucket (same one
# digitalocean/root.hcl uses). Not actually used by the current Scaleway
# leaf yet — it keeps a local backend override in its own terragrunt.hcl —
# but future Scaleway leaves can use this directly.
remote_state {
  backend = "s3"

  config = {
    endpoint                    = "https://tor1.digitaloceanspaces.com"
    region                      = "tor1"
    bucket                      = lookup(local.secrets, "DIGITALOCEAN_TERRAFORM_STATE_BUCKET", "")
    key                         = "scaleway/${path_relative_to_include()}/terraform.tfstate"
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
