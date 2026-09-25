module "data_email_key" {
  source           = "git::https://github.com/noisypigeon/pigeon-tf.git//digitalocean/access-key?ref=digitalocean/access-key/v0.1.0"
  name             = module.data_email.name
  permission       = "readwrite"
}

output "access_key" {
  description = "Spaces access key ID"
  value       = module.data_email_key.access_key
  sensitive   = true
}

output "secret_key" {
  description = "Spaces access key secret"
  value       = module.data_email_key.secret_key
  sensitive   = true
}
