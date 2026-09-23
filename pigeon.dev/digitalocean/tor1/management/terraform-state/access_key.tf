module "terraform_state_key" {
  source           = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/access-key?ref=digitalocean/access-key/v0.1.0"
  name             = module.terraform_state.name
  permission       = "fullaccess"
  is_bucket_scoped = false
}
