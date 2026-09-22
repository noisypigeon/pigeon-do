module "rolodex_email_key" {
  source           = "${local.pigeon_tf_root}/digitalocean/access-key"
  name             = module.rolodex_email.name
  permission       = "readwrite"
}
