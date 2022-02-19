module "aws_organizations_and_sso" {
  source  = "chris-qa-org/organzation-and-sso/aws"
  version = "1.0.0"

  region = "eu-west-2"

  sso_permission_sets = {
    "AdministratorAccess" = {
      description      = "Administrator Access",
      session_duration = "PT2H",
      managed_policies = [
        "AdministratorAccess"
      ]
    }
    "Billing" = {
      description      = "Billing access",
      session_duration = "PT4H",
      managed_policies = [
        "job-function/Billing"
      ]
    }
  }

  organization_config = {
    units = {
      "my-org-unit" = {
        accounts = {
          "my-account-name" = {
            email                      = "me@example.com"
            iam_user_access_to_billing = "ALLOW"
            group_assignments = {
              "Admins" = {
                permission_sets = [
                  "AdministratorAccess"
                ]
              }
            },
            user_assignments = {
              "Alex" = {
                permission_sets = [
                  "Billing"
                ]
              }
            }
          }
        }
      }
    },
    feature_set          = "ALL",
    enabled_policy_types = []
  }
}
