variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}

variable "organization_config" {
  description = "Organization configuration"
  type        = any
  default = {
    units = {
    }
  }
}

variable "enable_sso" {
  description = "Enable AWS SSO"
  type        = bool
  default     = true
}

variable "default_tags" {
  description = "Resource tags to apply across all resources"
  type        = map(string)
  default = {
    project = "terraform-aws-organization-and-sso"
  }
}
