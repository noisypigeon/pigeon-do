module "rolodex_email" {
  source           = "${local.pigeon_tf_root}/digitalocean/object-bucket-cold"
  name             = local.rolodex_email_bucket_name
  region           = local.primary_region
  project          = local.rolodex_project
}
