organization_config = {
  units = {
    "organization-unit-name" = {
      accounts = {
        "new-account-name" = {
          email = "new@example.com"
        },
        "existing-account-name" = {
          email                                  = "existing@example.com"
          set_iam_user_access_to_billing_setting = false
        }
      }
    }
  },
  service_access_principals = [
    "sso.amazonaws.com"
  ],
  feature_set = "ALL",
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]
}

enable_sso = true

default_tags = {
  project = "My Project"
}
