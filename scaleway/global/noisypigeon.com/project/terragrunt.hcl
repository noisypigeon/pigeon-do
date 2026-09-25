include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "domain" {
  path = find_in_parent_folders("noisypigeon.com.hcl")
}

terraform {
  source = get_terragrunt_dir()
}

# Deliberately kept on local state for now (Part 1 of the Scaleway rollout) —
# not moved to the shared S3 backend yet. See docs/adr/0008-scaleway-provider.md.
remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
