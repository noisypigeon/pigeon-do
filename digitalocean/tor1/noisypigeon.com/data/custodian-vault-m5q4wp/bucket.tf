module "custodian_vault_m5q4wp" {
  source  = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/cold-storage-bucket?ref=digitalocean/cold-storage-bucket/v0.1.0"
  name    = local.data_custodian_vault_m5q4wp_bucket_name
  region  = local.tor1_region
  project = local.data_project
}
