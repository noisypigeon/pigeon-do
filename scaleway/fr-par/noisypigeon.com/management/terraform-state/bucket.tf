module "terraform_state" {
  source            = "git::https://github.com/noisypigeon/pigeon-tf.git//scaleway/object-bucket?ref=scaleway/object-bucket/v1.0.0"
  enable_versioning = true
  namespace         = "management"
  name              = "terraform-state"
}
