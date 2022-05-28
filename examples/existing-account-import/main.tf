module "aws_organizations_and_sso" {
  source  = "chris-qa-org/organzation-and-sso/aws"
  version = "1.1.2"

  organization_config = {
    units = {
      "my-org-unit" = {
        accounts = {
          "my-account-name" = {
            email                      = "me@example.com"
            iam_user_access_to_billing = "NULL"
          }
        }
      }
    },
    feature_set          = "ALL",
    enabled_policy_types = []
  }
}
