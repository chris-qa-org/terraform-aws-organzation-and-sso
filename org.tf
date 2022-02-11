resource "aws_organizations_organization" "root" {
  aws_service_access_principals = toset(
    local.enable_sso ? concat(
      local.organization_config["service_access_principals"],
      ["sso.amazonaws.com"],
    ) : local.organization_config["service_access_principals"]
  )

  feature_set = local.organization_config["feature_set"]

  enabled_policy_types = local.organization_config["enabled_policy_types"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_organizational_unit" "unit" {
  for_each  = local.organization_config["units"]
  name      = each.key
  parent_id = aws_organizations_organization.root.roots[0].id

  tags = {
    "Name" = each.key
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "account" {
  for_each = {
    for account in flatten([
      for unit_name, unit in local.organization_config["units"] : [
        for account_name in keys(local.organization_config["units"][unit_name]["accounts"]) : merge(
          local.organization_config["units"][unit_name]["accounts"][account_name],
          { "org_unit_name" = unit_name },
          { "account_name" = account_name },
        )
      ]
    ]) : account["account_name"] => account
  }
  name  = each.key
  email = each.value["email"]

  iam_user_access_to_billing = lookup(each.value, "set_iam_user_access_to_billing_setting", true) ? "ALLOW" : null

  parent_id = aws_organizations_organizational_unit.unit[each.value["org_unit_name"]].id

  tags = {
    "Name" = each.key
  }

  lifecycle {
    prevent_destroy = true
  }
}
