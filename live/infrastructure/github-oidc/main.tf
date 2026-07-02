# ---------------------------------------------------------------------------
# GitHub Actions -> AWS via OIDC. No long-lived keys, no stored secrets.
# Creates: the GitHub OIDC identity provider + a role Actions can assume,
# scoped to THIS repo, with ReadOnly + Terraform-state access (plan-safe).
# ---------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = "HashiCorpQ"
    Environment = "foundation"
    Component   = "github-oidc"
    Account     = "infrastructure"
    ManagedBy   = "Terraform"
    Owner       = "iam.administrator+HashiCorpQ@webiq.cloud"
    CostCenter  = "learning-terraform"
  }
}

# Fetch GitHub's current OIDC thumbprint (correct, self-updating pattern).
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# Trust policy: only this repo, only the GitHub Actions audience.
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "gha_terraform" {
  name               = "gha-terraform-plan"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

# ReadOnly is enough for `terraform plan` (all the describe/get calls).
resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.gha_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# State bucket access so CI can read state and take the native lock.
data "aws_iam_policy_document" "state" {
  statement {
    sid       = "StateObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.state_bucket}/*"]
  }
  statement {
    sid       = "StateBucketList"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket}"]
  }
}

resource "aws_iam_role_policy" "state" {
  name   = "tf-state-access"
  role   = aws_iam_role.gha_terraform.id
  policy = data.aws_iam_policy_document.state.json
}
