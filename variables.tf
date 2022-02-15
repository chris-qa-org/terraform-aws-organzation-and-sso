variable "region" {
  description = "AWS Region"
  type        = string
}

variable "sso_permission_sets" {
  description = "AWS SSO Permission sets"
  type        = any
  default     = {}
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
