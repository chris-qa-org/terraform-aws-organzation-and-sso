# Accounts and permission assignments example

SSO permission sets can be defined with the `sso_permission_sets` parameter. The `managed_policies` items should be the name of the policy within AWS (The last part of the AWS)
The permission sets can then be assigned to users or groups in an account with `user_assignments` or `group_assigmnets`.

```
module "aws_organizations_and_sso" {
  source  = "chris-qa-org/organzation-and-sso/aws"
  version = "1.1.2"

  sso_permission_sets = {
    "AdministratorAccess" = {
      description = "Administrator Access",
      session_duration = "PT2H",
      managed_policies = [
        "AdministratorAccess"
      ]
    }
    "Billing" = {
      description = "Billing access",
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
```
