module "cli_email" {
  source    = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/standard-storage-bucket?ref=digitalocean/standard-storage-bucket/v0.1.0"
  namespace = "cli"
  name      = "email"
  project   = local.cli_project
  region    = local.primary_region
}
