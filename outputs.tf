output "aws_ssoadmin_instances" {
  description = "Attributes for the SSO Admin instances (`aws_ssoadmin_instances`: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances)"
  value       = data.aws_ssoadmin_instances.ssoadmin_instances
}

output "aws_organizations_organization" {
  description = "Attributes for the AWS Organization (`aws_organizations_organization`: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization#attributes-reference)"
  value       = aws_organizations_organization.root
}

output "aws_organizations_organizational_unit" {
  description = "Atrributes for the AWS Organizational Units (`aws_organizations_organizational_unit`): https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit#attributes-reference"
  value       = aws_organizations_organizational_unit.unit
}

output "aws_organizations_account" {
  description = "Attributes for the AWS Organization Accounts (`aws_organizations_account`): https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account#attributes-reference"
  value       = aws_organizations_account.account
}

output "aws_ssoadmin_permission_set" {
  description = "Attributes for the AWS SSO Permission Sets (`aws_ssoadmin_permission_set`): https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set"
  value       = aws_ssoadmin_permission_set.permission_set
}
