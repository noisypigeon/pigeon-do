module "rolodex_poutine_2021" {
  source  = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/cold-storage-bucket?ref=digitalocean/cold-storage-bucket/v0.1.0"
  name    = local.rolodex_poutine_2021_bucket_name
  region  = local.primary_region
  project = local.rolodex_project
}
