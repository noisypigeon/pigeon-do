module "management" {
  source      = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/project?ref=digitalocean/project/v0.1.0"
  name        = local.management_project
  environment = "Production"
  purpose     = "Operational / Developer tooling"
  is_default  = true
}
