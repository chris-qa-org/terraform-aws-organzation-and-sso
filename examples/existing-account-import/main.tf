module "aws_organizations_and_sso" {
  source  = "github.com/chris-qa-org/terraform-aws-organzation-and-sso"
  version = "0.4.1"

  region = "eu-west-2"

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
