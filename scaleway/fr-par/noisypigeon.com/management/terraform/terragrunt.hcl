include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = get_terragrunt_dir()
}
