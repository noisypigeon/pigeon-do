module "scratch_y6c1oc_key" {
  source           = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/access-key?ref=digitalocean/access-key/v0.1.0"
  name             = module.scratch_y6c1oc.name
  permission       = "read"
}

# output "access_key" {
#   description = "Spaces access key ID"
#   value       = module.scratch_y6c1oc_key.access_key
#   sensitive   = true
# }

# output "secret_key" {
#   description = "Spaces access key secret"
#   value       = module.scratch_y6c1oc_key.secret_key
#   sensitive   = true
# }
