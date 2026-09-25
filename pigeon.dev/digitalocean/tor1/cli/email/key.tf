module "cli_email_key" {
  source     = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/access-key?ref=digitalocean/access-key/v0.1.0"
  name       = module.cli_email.name
  permission = "readwrite"
}
