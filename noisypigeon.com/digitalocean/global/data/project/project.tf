module "data" {
  source      = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/project?ref=digitalocean/project/v0.1.0"
  name        = local.data_project
  environment = "Production"
  purpose     = "Operational / Object storage"
}
