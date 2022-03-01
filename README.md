# AWS Organization and SSO terraform module

[![Terraform CI](https://github.com/chris-qa-org/terraform-aws-organzation-and-sso/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/chris-qa-org/terraform-aws-organzation-and-sso/actions/workflows/main.yml?branch=main)
[![GitHub release](https://img.shields.io/github/release/chris-qa-org/terraform-aws-organzation-and-sso.svg)](https://github.com/chris-qa-org/terraform-aws-organzation-and-sso/releases/)

This module creates and manages [AWS Organizations][1], [Organization units][2], [Accounts][3], [SSO Permission sets][5] and group/user assignments.

## Limitations

- Identity store Users and Groups must be created manually, as the identity store api does not currently support creating users or groups (https://github.com/hashicorp/terraform-provider-aws/issues/18812)
- SSO must be enabled manually

## Usage

```hcl
module "aws_organizations_and_sso" {
  source  = "chris-qa-org/organzation-and-sso/aws"
  version = "1.1.0"

  sso_permission_sets = {
    "admin" = {
      description = "Administrator access",
      relay_state = "https://console.aws.amazon.com/billing/home?region=eu-west-2#/",
      session_duration = "PT1H", ## ISO-8601 standard (https://en.wikipedia.org/wiki/ISO_8601#Time_intervals)
      managed_policies = [
        "AdministratorAccess"
      ],
      inline_policy = data.aws_iam_policy_document.example.json,
    },
    "read-only" = {
      description = "Read Only",
      relay_state = "https://console.aws.amazon.com/ec2/v2/home?region=eu-west-2#/",
      managed_policies = [
        "AWSReadOnlyAccess"
      ]
    },
    "billing" = {
      description = "Billing Access",
      relay_state = "https://console.aws.amazon.com/billing/home?#/",
      managed_policies = [
        "job-function/Billing"
      ]
    }
  }

  organization_config = {
    units = {
      "organization-unit-name" = {
        accounts = {
          "new-account-name" = {
            email = "new@example.com",
            group_assignments = {
              "SysAdmins" = {
                permission_sets = [
                  "admin"
                ]
              },
              "External" = {
                permission_sets = [
                  "read-only"
                ]
              }
            }
            user_assignments = {
              "Alex" = {
                permission_sets = [
                  "billing"
                ]
              }
            }
          },
          "existing-account-name" = {
            email = "existing@example.com"
            # If the account has been imported into terrafrom, this must be set to "NULL"
            # This behaviour cannot be changed once the account is created (only the root user account will be able to change it)
            iam_user_access_to_billing = "NULL"
            group_assignments = {
              "SysAdmins" = {
                permission_sets = [
                  "admin"
                ]
              }
            }
            user_assignments = {
              "Alex" = {
                permission_sets = [
                  "billing"
                ]
              }
            }
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

### Permission sets config

- `sso_permission_sets`
  - Description: SSO Permission Set definitions
  - Value: SSO Permission Set definitions (`map(any)`)
- `sso_permission_sets.<permission-set-name>`
  - Description: SSO Permission Set definition
  - Key: Name of SSO Permission Set definition
  - Value: SSO Permission Set definition (`map(any)`)
- `sso_permission_sets.<permission-set-name>.description`
  - Description: The description of the Permission Set
  - Value: Description (`string`)
- `sso_permission_sets.<permission-set-name>.relay_state`
  - Description: The relay state URL used to redirect users within the application during the federation authentication process
  - Value: Relay state (`string`)
- `sso_permission_sets.<permission-set-name>.session_duration`
  - Description: The length of time that the application user sessions are valid in the ISO-8601 standard
  - Value: Session duration (`string`)
- `sso_permission_sets.<permission-set-name>.managed_policies`
  - Description: Managed policies to associate with the permission set
  - Value: Names of AWS managed polices (`list`)
- `sso_permission_sets.<permission-set-name>.inline_policy`
  - Description: The IAM inline policy to attach to the Permission Set
  - Value: JSON formatted policy (`string`)

### Organization config

- `organization_config.units`
  - Description: Organization Unit definitions
  - Value: Organization unit definitions (`map(any)`)
- `organization_config.units.<org-unit-name>`
  - Description: Organization Unit definition (`map(any)`)
  - Key: The name for the organizational unit (`string`)
  - Value: Organization unit configuration (`map(any)`)
- `organization_config.units.<org-unit-name>.accounts`
  - Description: Organization account definitions (`map(any)`)
  - Value: Organization account definitions `map(any)`
- `organization_config.units.<org-unit-name>.accounts.<account-name>`
  - Description: Organization account definition (`map(any)`)
  - Key: A friendly name for the member account (`string`)
  - Value: Account configuration (`map(any)`)
- `organization_config.units.<org-name>.accounts.<account-name>.email`
  - Description: The email address of the owner to assign to the new member account. This email address must not already be associated with another AWS account.
  - Value: Email of root user `string`
- `organization_config.units.<org-name>.accounts.<account-name>.iam_user_access_to_billing`
  - Description: If set to ALLOW, the new account enables IAM users to access account billing information if they have the required permissions. If set to DENY, then only the root user of the new account can access account billing information.
  - Value: `ALLOW`/`DENY`/`NULL` (`string`)
  - Default: `ALLOW`
  - Note: This must be set to "NULL" if you are terraform importing an AWS account, otherwise it will atttempt to remove the account from the Organization, and create a new account.
- `organization_config.units.<org-name>.accounts.<account-name>.group_assignments`
  - Description: Group assignment definitions.
  - Value: Group assignment definition (`map`)
- `organization_config.units.<org-name>.accounts.<account-name>.group_assignments.<group_name>`
  - Description: Group assignment definition
  - Key: Group name
  - Value: Group assignment config (`map`)
- `organization_config.units.<org-name>.accounts.<account-name>.group_assignments.<group_name>.permission_sets`
  - Description: Group assignment definition
  - Value: Permission set names (`list`)
- `organization_config.units.<org-name>.accounts.<account-name>.user_assignments`
  - Description: User assignment definitions.
  - Value: User assignment definition (`map`)
- `organization_config.units.<org-name>.accounts.<account-name>.user_assignments.<user_name>`
  - Description: User assignment definition
  - Key: User name
  - Value: User assignment config (`map`)
- `organization_config.units.<org-name>.accounts.<account-name>.group_assignments.<user_name>.permission_sets`
  - Description: User assignment definition
  - Value: Permission set names (`list`)
- `organization_config.service_access_principals`
  - Description: List of AWS service principal names for which you want to enable integration with your organization. This is typically in the form of a URL, such as service-abbreviation.amazonaws.com. Organization must have feature_set set to ALL.
  - Value: Service access principals (`list`)
- `organization_config.feature_set`
  - Description: Specify "ALL" or "CONSOLIDATED_BILLING".
  - Value: Feature set (`string`)
- `organization_config.enabled_policy_types`
  - Description: List of Organizations policy types to enable in the Organization Root. Organization must have feature_set set to ALL. For additional information about valid policy types
  - Value: Enabled policy types (`list`)


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
| [aws_ssoadmin_account_assignment.group_assignment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_account_assignment.user_assignment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_managed_policy_attachment.attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.permission_set](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_identitystore_group.aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_identitystore_user.aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_user) | data source |
| [aws_ssoadmin_instances.ssoadmin_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_sso"></a> [enable\_sso](#input\_enable\_sso) | Enable AWS SSO | `bool` | `true` | no |
| <a name="input_organization_config"></a> [organization\_config](#input\_organization\_config) | Organization configuration | `any` | <pre>{<br>  "units": {}<br>}</pre> | no |
| <a name="input_sso_permission_sets"></a> [sso\_permission\_sets](#input\_sso\_permission\_sets) | AWS SSO Permission sets | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_organizations_account"></a> [aws\_organizations\_account](#output\_aws\_organizations\_account) | Attributes for the AWS Organization Accounts (`aws_organizations_account`): https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account#attributes-reference |
| <a name="output_aws_organizations_organization"></a> [aws\_organizations\_organization](#output\_aws\_organizations\_organization) | Attributes for the AWS Organization (`aws_organizations_organization`: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization#attributes-reference) |
| <a name="output_aws_organizations_organizational_unit"></a> [aws\_organizations\_organizational\_unit](#output\_aws\_organizations\_organizational\_unit) | Atrributes for the AWS Organizational Units (`aws_organizations_organizational_unit`): https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit#attributes-reference |
| <a name="output_aws_ssoadmin_instances"></a> [aws\_ssoadmin\_instances](#output\_aws\_ssoadmin\_instances) | Attributes for the SSO Admin instances (`aws_ssoadmin_instances`: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) |
| <a name="output_aws_ssoadmin_permission_set"></a> [aws\_ssoadmin\_permission\_set](#output\_aws\_ssoadmin\_permission\_set) | Attributes for the AWS SSO Permission Sets (`aws_ssoadmin_permission_set`): https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set |
<!-- END_TF_DOCS -->

[1]: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_org.html
[2]: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_ous.html
[3]: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts.html
[4]: https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html
[5]: https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html
