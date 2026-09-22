module "terraform_state_key" {
  source           = "${local.pigeon_tf_root}/digitalocean/access-key"
  name             = module.terraform_state.name
  permission       = "fullaccess"
  is_bucket_scoped = false
}
