terraform {
  backend "s3" {
    bucket       = "webiq-tfstate-715841359129-us-east-1"
    key          = "infrastructure/github-oidc/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
