module "custodian_vault_m5q4wp_key" {
  source           = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/access-key?ref=digitalocean/access-key/v0.1.0"
  name             = module.custodian_vault_m5q4wp.name
  permission       = "read"
}

# output "access_key" {
#   description = "Spaces access key ID"
#   value       = module.custodian_vault_m5q4wp_key.access_key
#   sensitive   = true
# }

# output "secret_key" {
#   description = "Spaces access key secret"
#   value       = module.custodian_vault_m5q4wp_key.secret_key
#   sensitive   = true
# }
