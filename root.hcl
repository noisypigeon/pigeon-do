generate "env" {
  path      = "env_generated.tf"
  if_exists = "overwrite"
  contents  = file("${get_repo_root()}/env.tf")
}

locals {
  env_ancestor_paths = [
    "${dirname(get_terragrunt_dir())}/env.tf",
    "${dirname(dirname(get_terragrunt_dir()))}/env.tf",
    "${dirname(dirname(dirname(get_terragrunt_dir())))}/env.tf",
    "${dirname(dirname(dirname(dirname(get_terragrunt_dir()))))}/env.tf",
    "${dirname(dirname(dirname(dirname(dirname(get_terragrunt_dir())))))}/env.tf",
  ]

  # Secrets: read from a repo-root ".env" (KEY=value, one per line, no
  # quoting). This repo has a single DigitalOcean team/Cloudflare zone, so
  # unlike topology-v1 there is no tree-level ".env" override chain — just
  # the root file. Precedence, highest first: real shell env var > root .env.
  root_env_path = "${get_repo_root()}/.env"

  root_secrets = { for pair in [
    for line in split("\n", fileexists(local.root_env_path) ? file(local.root_env_path) : "") :
    regex("^([^=]+)=(.*)$", trimspace(line))
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
    && can(regex("^([^=]+)=(.*)$", trimspace(line)))
  ] : trimspace(pair[0]) => trimspace(pair[1]) }

  secrets = local.root_secrets
}

generate "env_ancestors" {
  path      = "env_ancestors_generated.tf"
  if_exists = "overwrite"
  contents = join("\n\n", [
    for p in local.env_ancestor_paths :
    file(p)
    if fileexists(p) && abspath(p) != abspath("${get_repo_root()}/env.tf")
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
    # from the root .env, same as the provider block above.
    bucket                      = lookup(local.secrets, "DIGITALOCEAN_TERRAFORM_STATE_BUCKET", "")
    key                         = "${path_relative_to_include()}/terraform.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true

    access_key = get_env("DIGITALOCEAN_SPACES_ACCESS_ID", lookup(local.secrets, "DIGITALOCEAN_SPACES_ACCESS_ID", ""))
    secret_key = get_env("DIGITALOCEAN_SPACES_SECRET_KEY", lookup(local.secrets, "DIGITALOCEAN_SPACES_SECRET_KEY", ""))
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}
