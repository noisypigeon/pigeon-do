module "cli" {
  source      = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/project?ref=digitalocean/project/v0.1.0"
  name        = local.cli_project
  environment = "Development"
  purpose     = "Operational / Developer tooling"
}
