locals {
  # Digital Ocean Regions
  tor1_region = "tor1"
  sfo3_region = "sfo3"

  # Digital Ocean Projects
  management_project  = "Management"
  data_project        = "Data"
  data_import_project = "Data Import"

  # Secrets: read from this domain's own repo-root ".env" file (KEY=value,
  # one per line, no quoting) — one per DigitalOcean account/domain, see
  # docs/adr/0007-multiple-root-directories.md and docs/adr/0008-scaleway-provider.md
  # (provider-first layout: domain is no longer a directory ancestor, so
  # this file lives at the true repo root and is included directly by
  # every leaf under this domain, not found via directory nesting).
  # Precedence, highest first: real shell env var > this domain's .env.
  root_env_path = "${get_repo_root()}/noisypigeon.com.env"

  root_secrets = { for pair in [
    for line in split("\n", fileexists(local.root_env_path) ? file(local.root_env_path) : "") :
    regex("^([^=]+)=(.*)$", trimspace(line))
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
    && can(regex("^([^=]+)=(.*)$", trimspace(line)))
  ] : trimspace(pair[0]) => trimspace(pair[1]) }

  secrets = local.root_secrets

  # Bucket-name secrets: any .env key prefixed BUCKET_NAME_ is exposed as a
  # local named by stripping the prefix and appending _bucket_name, e.g.
  # BUCKET_NAME_ROLODEX_EMAIL -> local.rolodex_email_bucket_name. See
  # docs/adr/0006-automatic-bucket-name-locals.md. Stays here (not in
  # common.hcl) since it depends on local.secrets, defined above in this
  # same file — see docs/adr/0007-multiple-root-directories.md.
  bucket_name_secrets = {
    for k, v in local.secrets : "${lower(trimprefix(k, "BUCKET_NAME_"))}_bucket_name" => get_env(k, v)
    if startswith(k, "BUCKET_NAME_")
  }
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

generate "bucket_names" {
  path      = "bucket_names_generated.tf"
  if_exists = "overwrite"
  contents  = <<EOF
locals {
${join("\n", [for k, v in local.bucket_name_secrets : "  ${k} = \"${v}\""])}
}
EOF
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

    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.0"
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

provider "scaleway" {
  access_key      = "${get_env("SCALEWAY_ACCESS_KEY", lookup(local.secrets, "SCALEWAY_ACCESS_KEY", ""))}"
  secret_key      = "${get_env("SCALEWAY_SECRET_KEY", lookup(local.secrets, "SCALEWAY_SECRET_KEY", ""))}"
  organization_id = "${get_env("SCALEWAY_ORGANIZATION_ID", lookup(local.secrets, "SCALEWAY_ORGANIZATION_ID", ""))}"
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
    # from this domain's own .env, same as the provider block above. This
    # bucket is shared: pigeon.dev.hcl points at the same bucket/credentials
    # (copied into pigeon.dev.env) for its own leaves — see
    # docs/adr/0008-scaleway-provider.md.
    bucket = lookup(local.secrets, "DIGITALOCEAN_TERRAFORM_STATE_BUCKET", "")
    # No manual domain prefix needed: with the provider-first layout, the
    # domain name is already a segment of every leaf's own path (e.g.
    # cloudflare/global/noisypigeon.com/fastmail), so path_relative_to_include()
    # naturally includes it — see docs/adr/0008-scaleway-provider.md.
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
