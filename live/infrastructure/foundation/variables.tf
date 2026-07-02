variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "account_alias" {
  type    = string
  default = "infrastructure"
}
variable "name_prefix" {
  type    = string
  default = "webiq-infra"
}
variable "budget_limit_usd" {
  description = "Monthly cost budget (USD)."
  type        = number
  default     = 50
}
variable "budget_notification_email" {
  type    = string
  default = "aws.administrator+infrastructure@webiq.cloud"
}
