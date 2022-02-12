# AWS Organization and SSO terraform module

This module creates an [AWS Organization][1], [Organization units][2] and [Accounts][3].  
The aim is for it to also create and manage [AWS SSO (AWS Single Sign-on)][4]

[![Terraform CI](https://github.com/chris-qa-org/terraform-aws-organzation-and-sso/actions/workflows/main.yml/badge.svg)](https://github.com/chris-qa-org/terraform-aws-organzation-and-sso/actions/workflows/main.yml)

## Usage

```hcl
module "aws_organizations_and_sso" {
  source  = "github.com/chris-qa-org/terraform-aws-organzation-and-sso"
  version = "0.1.0"

  organization_config = {
    units = {
      "organization-unit-name" = {
        accounts = {
          "new-account-name" = {
            email = "new@example.com"
          },
          "existing-account-name" = {
            email                                  = "existing@example.com"
            set_iam_user_access_to_billing_setting = false  ## See `set_iam_user_access_to_billing_setting` note in [Organization config]
          }
        }
      }
    },
    service_access_principals = [
      "sso.amazonaws.com" ## Automatically added if `enable_sso` is enabled
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
}
```

### Organization config

- `organization_config.units`
  - Description: Organization Unit definitions
  - Value: Organization unit definitions (`map(any)`)
- `organization_config.units.<org-unit-name>`
  - Description: Organization Unit definition (`map(any)`)
  - Key: Name of child Organization to create (`string`)
  - Value: Organization unit configuration (`map(any)`)
- `organization_config.units.<org-unit-name>.accounts`
  - Description: Organization account definitions (`map(any)`)
  - Value: Organization account definitions `map(any)`
- `organization_config.units.<org-unit-name>.accounts.<account-name>`
  - Description: Organization account definition (`map(any)`)
  - Key: Name of account to create (`string`)
  - Value: Account configuration (`map(any)`)
- `organization_config.units.<org-name>.accounts.<account-name>.email`
  - Description: Email of root user
  - Value: Email of root user `string`
- `organization_config.units.<org-name>.accounts.<account-name>.set_iam_user_access_to_billing_setting`
  - Description: Set the `iam_user_access_to_billing` parameter to `ALLOW`
  - Value: `true`/`fale` (`bool`)
  - Default: true
  - Note: This must be set to `false` if you are terraform importing an AWS account that did not have `iam_user_access_to_billing` set during creation, otherwise it will atttempt to remove the account from the Organization, and create a new account

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_organizations_account.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_organization.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.unit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Resource tags to apply across all resources | `map(string)` | <pre>{<br>  "project": "terraform-aws-organization-and-sso"<br>}</pre> | no |
| <a name="input_enable_sso"></a> [enable\_sso](#input\_enable\_sso) | Enable AWS SSO | `bool` | `true` | no |
| <a name="input_organization_config"></a> [organization\_config](#input\_organization\_config) | Organization configuration | `map(any)` | <pre>{<br>  "units": {}<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"eu-west-2"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

[1]: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_org.html
[2]: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_ous.html
[3]: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts.html
[4]: https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html
