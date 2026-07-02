# Bootstrap runs with LOCAL state. Credentials from env (AWS_PROFILE).
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project    = "HashiCorpQ"
      Layer      = "bootstrap"
      ManagedBy  = "Terraform"
      Owner      = "iam.administrator+HashiCorpQ@webiq.cloud"
      Account    = "infrastructure"
      CostCenter = "learning-terraform"
    }
  }
}
