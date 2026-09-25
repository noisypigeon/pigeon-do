module "terraform_deployer" {
  source = "git::https://github.com/noisypigeon/pigeon-tf.git//scaleway/iam-policy?ref=scaleway/iam-policy/v1.1.0"
  name   = "terraform-deployer"
  project_ids = [
    local.scaleway_project_id_noisypigeon_com,
    local.scaleway_project_id_pigeon_dev
  ]
  project_permission_sets = [
    "InstancesFullAccess",
    "ObjectStorageFullAccess",
    "VPCFullAccess",
  ]
  organization_id = local.scaleway_organization_id
  org_permission_sets = [
    "ProjectManager",
    "IAMManager",
    "IAMApplicationManager"
  ]
  expires_at = "2027-09-25T22:32:12Z"
}

output "access_key" {
  description = "IAM API key access key"
  value       = module.terraform_deployer.access_key
  sensitive   = true
}

output "secret_key" {
  description = "IAM API key secret key"
  value       = module.terraform_deployer.secret_key
  sensitive   = true
}
