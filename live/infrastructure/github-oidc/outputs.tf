output "role_arn" {
  description = "Set this as the GitHub repo variable AWS_TF_ROLE_ARN."
  value       = aws_iam_role.gha_terraform.arn
}
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
