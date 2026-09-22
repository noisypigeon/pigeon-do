module "management" {
  source      = "${local.pigeon_tf_root}/digitalocean/project"
  name        = local.management_project
  environment = "Production"
  purpose     = "Operational / Developer tooling"
  is_default  = true
}
