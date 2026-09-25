include "common" {
  path = find_in_parent_folders("common.hcl")
}

include "domain" {
  path = find_in_parent_folders("noisypigeon.com.hcl")
}
