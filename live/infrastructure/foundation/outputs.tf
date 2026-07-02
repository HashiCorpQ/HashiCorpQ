output "account_id" { value = data.aws_caller_identity.current.account_id }
output "artifacts_bucket" { value = module.artifacts_bucket.bucket_id }
output "ssm_parameter_name" { value = aws_ssm_parameter.greeting.name }
output "budget_name" { value = aws_budgets_budget.monthly.name }
