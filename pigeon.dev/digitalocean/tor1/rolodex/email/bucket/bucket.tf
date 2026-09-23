module "rolodex_email" {
  source  = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/cold-storage-bucket?ref=digitalocean/cold-storage-bucket/v0.1.0"
  name    = local.rolodex_email_bucket_name
  region  = local.primary_region
  project = local.rolodex_project
}
