locals {
  # Shared locals inherited by every stack via root.hcl's `generate "env"` block
  # per docs/adr/0001-terragrunt-terraform-bootstrap.md.

  # Digital Ocean Regions
  primary_region = "tor1"

  # Digital Ocean Projects
  management_project = "Management"
  data_project       = "Data"
}
