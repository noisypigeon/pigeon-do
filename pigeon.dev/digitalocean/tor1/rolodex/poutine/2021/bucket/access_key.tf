module "rolodex_poutine_2021_key" {
  source     = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/access-key?ref=digitalocean/access-key/v0.1.0"
  name       = module.rolodex_poutine_2021.name
  permission = "readwrite"
}
