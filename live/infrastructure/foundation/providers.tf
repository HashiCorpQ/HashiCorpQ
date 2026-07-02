# No hardcoded profile: uses the standard AWS credential chain.
#   Local  -> export AWS_PROFILE=AWSAdministratorAccess-715841359129
#   CI     -> OIDC-assumed role env vars (see .github/workflows/terraform.yml)
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}
