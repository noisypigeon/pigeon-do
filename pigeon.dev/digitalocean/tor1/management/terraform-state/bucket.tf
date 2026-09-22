module "terraform_state" {
  source    = "${local.pigeon_tf_root}/digitalocean/object-bucket"
  namespace = "pigeon-dev"
  name      = "terraform-state"
  project   = local.management_project
  region    = local.primary_region
}
