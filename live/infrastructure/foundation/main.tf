# ---------------------------------------------------------------------------
# Stage 1 foundation -- Infrastructure account (715841359129).
# Exercises the full loop: remote state + locking, reusable module,
# default tagging, a stored parameter, and a FinOps budget guardrail.
# ---------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = "HashiCorpQ"
    Environment = "foundation"
    Account     = var.account_alias
    ManagedBy   = "Terraform"
    Owner       = "iam.administrator+HashiCorpQ@webiq.cloud"
    CostCenter  = "learning-terraform"
  }
}

data "aws_caller_identity" "current" {}

module "artifacts_bucket" {
  source        = "../../../modules/secure-bucket"
  name          = "${var.name_prefix}-artifacts-${data.aws_caller_identity.current.account_id}"
  versioning    = true
  force_destroy = true # ephemeral learning bucket -- allows test-then-destroy
  tags          = { Purpose = "stage1-artifacts" }
}

resource "aws_ssm_parameter" "greeting" {
  name  = "/${var.name_prefix}/foundation/greeting"
  type  = "String"
  value = "Terraform Stage 1 validated in ${var.aws_region}"
}

resource "aws_budgets_budget" "monthly" {
  name         = "${var.name_prefix}-monthly-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.budget_limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_notification_email]
  }
}
