module "backblaze_import" {
  source  = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/cold-storage-bucket?ref=digitalocean/cold-storage-bucket/v0.1.0"
  name    = local.backblaze_import_bucket_name
  region  = local.tor1_region
  project = local.data_import_project
}
