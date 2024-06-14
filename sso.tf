data "aws_ssoadmin_instances" "ssoadmin_instances" {}

data "aws_identitystore_group" "aws" {
  for_each = local.enable_sso ? toset(
    flatten([
      for account in local.accounts : keys(lookup(account, "group_assignments", {}))
    ])
  ) : toset([])

  identity_store_id = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.key
    }
  }
}

data "aws_identitystore_user" "aws" {
  for_each = local.enable_sso ? toset(
    flatten([
      for account in local.accounts : keys(lookup(account, "user_assignments", {}))
    ])
  ) : toset([])

  identity_store_id = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}

resource "aws_ssoadmin_permission_set" "permission_set" {
  for_each = local.enable_sso ? local.sso_permission_sets : null

  instance_arn     = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.arns)[0]
  name             = each.key
  description      = lookup(each.value, "description", null)
  relay_state      = lookup(each.value, "relay_state", null)
  session_duration = lookup(each.value, "session_duration", "PT1H")
}

resource "aws_ssoadmin_managed_policy_attachment" "attachment" {
  for_each = local.enable_sso ? merge([
    for permission_set_name, permission_set in local.sso_permission_sets : {
      for managed_policy_name in permission_set["managed_policies"] : "${permission_set_name}_${managed_policy_name}" => {
        permission_set_name = permission_set_name
        managed_policy_name = managed_policy_name
      }
    }
  ]...) : {}

  instance_arn       = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/${each.value["managed_policy_name"]}"
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value["permission_set_name"]].arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "policy" {
  for_each = local.enable_sso ? {
    for permission_set_name in flatten([
      for permission_set_name, permission_set in local.sso_permission_sets : permission_set_name if lookup(local.sso_permission_sets[permission_set_name], "inline_policy", "") != ""
    ]) : permission_set_name => local.sso_permission_sets[permission_set_name]["inline_policy"]
  } : {}

  inline_policy      = each.value
  instance_arn       = aws_ssoadmin_permission_set.permission_set[each.key].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.key].arn
}

resource "aws_ssoadmin_account_assignment" "group_assignment" {
  for_each = local.enable_sso ? merge(flatten([
    for unit_name, unit in local.organization_config["units"] : [
      for account_name in keys(local.organization_config["units"][unit_name]["accounts"]) : [
        for group_name, group_assignments in lookup(local.organization_config["units"][unit_name]["accounts"][account_name], "group_assignments", {}) : {
          for permission_set in group_assignments["permission_sets"] : "${account_name}_${group_name}_${permission_set}" => {
            account_name   = account_name
            group_name     = group_name
            permission_set = permission_set
          }
        }
      ]
    ]
  ])...) : {}

  instance_arn       = aws_ssoadmin_permission_set.permission_set[each.value["permission_set"]].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value["permission_set"]].arn

  principal_id   = data.aws_identitystore_group.aws[each.value["group_name"]].group_id
  principal_type = "GROUP"

  target_id   = aws_organizations_account.account[each.value["account_name"]].id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "user_assignment" {
  for_each = local.enable_sso ? merge(flatten([
    for unit_name, unit in local.organization_config["units"] : [
      for account_name in keys(local.organization_config["units"][unit_name]["accounts"]) : [
        for user_name, user_assignments in lookup(local.organization_config["units"][unit_name]["accounts"][account_name], "user_assignments", {}) : {
          for permission_set in user_assignments["permission_sets"] : "${account_name}_${user_name}_${permission_set}" => {
            account_name   = account_name
            user_name      = user_name
            permission_set = permission_set
          }
        }
      ]
    ]
  ])...) : {}

  instance_arn       = aws_ssoadmin_permission_set.permission_set[each.value["permission_set"]].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value["permission_set"]].arn

  principal_id   = data.aws_identitystore_user.aws[each.value["user_name"]].user_id
  principal_type = "USER"

  target_id   = aws_organizations_account.account[each.value["account_name"]].id
  target_type = "AWS_ACCOUNT"
}
