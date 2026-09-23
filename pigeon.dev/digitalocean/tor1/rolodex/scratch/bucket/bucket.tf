module "rolodex_scratch" {
  source    = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/standard-storage-bucket?ref=digitalocean/standard-storage-bucket/v0.1.0"
  namespace = "rolodex"
  name      = "scratch"
  project   = local.rolodex_project
  region    = local.primary_region
}
