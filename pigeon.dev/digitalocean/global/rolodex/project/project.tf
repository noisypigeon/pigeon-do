module "rolodex" {
  source      = "${local.pigeon_tf_root}/digitalocean/project"
  name        = local.rolodex_project
  environment = "Production"
  purpose     = "Operational / Object Storage"
}
