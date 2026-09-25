module "terraform_state_key" {
  source           = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/access-key?ref=digitalocean/access-key/v0.1.0"
  name             = module.terraform_state.name
  permission       = "fullaccess"
  is_bucket_scoped = false
}

output "access_key" {
  description = "Spaces access key ID"
  value       = module.terraform_state_key.access_key
  sensitive   = true
}

output "secret_key" {
  description = "Spaces access key secret"
  value       = module.terraform_state_key.secret_key
  sensitive   = true
}
