provider "aws" {
  region = local.region
  default_tags {
    tags = local.default_tags
  }
}
