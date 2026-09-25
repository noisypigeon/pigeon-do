generate "env" {
  path      = "env_generated.tf"
  if_exists = "overwrite"
  contents  = file(find_in_parent_folders("env.tf"))
}

locals {
  env_ancestor_paths = [
    "${dirname(get_terragrunt_dir())}/env.tf",
    "${dirname(dirname(get_terragrunt_dir()))}/env.tf",
    "${dirname(dirname(dirname(get_terragrunt_dir())))}/env.tf",
    "${dirname(dirname(dirname(dirname(get_terragrunt_dir()))))}/env.tf",
    "${dirname(dirname(dirname(dirname(dirname(get_terragrunt_dir())))))}/env.tf",
  ]

  # Secrets: read from this root directory's own ".env" (KEY=value, one per
  # line, no quoting) — one per DigitalOcean account/domain, see
  # docs/adr/0007-multiple-root-directories.md. Precedence, highest first:
  # real shell env var > this root's .env.
  root_env_path = find_in_parent_folders(".env", "")

  root_secrets = { for pair in [
    for line in split("\n", fileexists(local.root_env_path) ? file(local.root_env_path) : "") :
    regex("^([^=]+)=(.*)$", trimspace(line))
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
    && can(regex("^([^=]+)=(.*)$", trimspace(line)))
  ] : trimspace(pair[0]) => trimspace(pair[1]) }

  secrets = local.root_secrets

  # No BUCKET_NAME_*/CLOUDFLARE_* keys for this account yet — when this
  # domain needs Cloudflare zone IDs or named buckets, add a
  # generate "cloudflare_ids"/"bucket_names" block here following
  # pigeon.dev/root.hcl's pattern (see docs/adr/0004, 0006, 0007). Not
  # shared via common.hcl: those blocks depend on local.secrets, which is
  # defined per-account in this same file.
}

generate "env_ancestors" {
  path      = "env_ancestors_generated.tf"
  if_exists = "overwrite"
  contents = join("\n\n", [
    for p in local.env_ancestor_paths :
    file(p)
    if fileexists(p) && abspath(p) != abspath(find_in_parent_folders("env.tf"))
  ])
}

generate "provider" {
  path      = "provider_generated.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "digitalocean" {
  token             = "${get_env("DIGITALOCEAN_TOKEN", lookup(local.secrets, "DIGITALOCEAN_TOKEN", ""))}"
  spaces_access_id  = "${get_env("DIGITALOCEAN_SPACES_ACCESS_ID", lookup(local.secrets, "DIGITALOCEAN_SPACES_ACCESS_ID", ""))}"
  spaces_secret_key = "${get_env("DIGITALOCEAN_SPACES_SECRET_KEY", lookup(local.secrets, "DIGITALOCEAN_SPACES_SECRET_KEY", ""))}"
}

provider "cloudflare" {
  api_token         = "${get_env("CLOUDFLARE_TOKEN", lookup(local.secrets, "CLOUDFLARE_TOKEN", ""))}"
}
EOF
}

# Configure backend to use the Spaces bucket
remote_state {
  backend = "s3"

  config = {
    endpoint = "https://tor1.digitaloceanspaces.com"
    region   = "tor1"
    # The state bucket, Spaces access key, and Spaces secret key all come
    # from this root directory's own .env, same as the provider block above.
    bucket                      = lookup(local.secrets, "DIGITALOCEAN_TERRAFORM_STATE_BUCKET", "")
    key                         = "noisypigeon.com/${path_relative_to_include()}/terraform.tfstate"
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
