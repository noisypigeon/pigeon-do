module "backblaze_import_key" {
  source           = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/access-key?ref=digitalocean/access-key/v0.1.0"
  name             = module.backblaze_import.name
  permission       = "read"
}

# output "access_key" {
#   description = "Spaces access key ID"
#   value       = module.backblaze_import_key.access_key
#   sensitive   = true
# }

# output "secret_key" {
#   description = "Spaces access key secret"
#   value       = module.backblaze_import_key.secret_key
#   sensitive   = true
# }
