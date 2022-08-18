locals {
  sso_permission_sets = var.sso_permission_sets
  organization_config = var.organization_config
  enable_sso          = var.enable_sso
  accounts = flatten([
    for unit_name, unit in local.organization_config["units"] : [
      for account_name in keys(local.organization_config["units"][unit_name]["accounts"]) : local.organization_config["units"][unit_name]["accounts"][account_name]
    ]
  ])
}
