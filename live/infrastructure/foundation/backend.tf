# Remote state -- native S3 locking. No profile here: credentials come from
# the environment (AWS_PROFILE locally, OIDC role in CI).
terraform {
  backend "s3" {
    bucket       = "webiq-tfstate-715841359129-us-east-1"
    key          = "infrastructure/foundation/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
