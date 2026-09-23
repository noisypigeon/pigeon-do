module "terraform_state" {
  source    = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/standard-storage-bucket?ref=digitalocean/standard-storage-bucket/v0.1.0"
  namespace = "pigeon-dev"
  name      = "terraform-state"
  project   = local.management_project
  region    = local.primary_region
}
