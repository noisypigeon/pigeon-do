module "rolodex" {
  source      = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/project?ref=digitalocean/project/v0.1.0"
  name        = local.rolodex_project
  environment = "Production"
  purpose     = "Operational / Object Storage"
}
