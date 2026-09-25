locals {
  # Local filesystem path to the pigeon-tf modules checkout (see
  # docs/adr/0002-pigeon-tf-scaffold.md). Override via PIGEON_TF_PATH;
  # default assumes pigeon-tf is cloned as a sibling directory to this repo.
  # Repo-wide, not account-scoped, so this stays on get_repo_root() even
  # though it's included alongside a per-account root.hcl (see
  # docs/adr/0007-multiple-root-directories.md). Self-contained (doesn't
  # reference local.secrets), unlike cloudflare_ids/bucket_names below,
  # which stay in each account's own root.hcl: Terragrunt evaluates each
  # include's locals independently, so a local here can't forward-reference
  # a local defined only in a sibling include.
  pigeon_tf_root = get_env("PIGEON_TF_PATH", "${dirname(get_repo_root())}/pigeon-tf")
}

generate "pigeon_tf" {
  path      = "pigeon_tf_generated.tf"
  if_exists = "overwrite"
  contents  = <<EOF
locals {
  pigeon_tf_root = "${local.pigeon_tf_root}"
}
EOF
}
