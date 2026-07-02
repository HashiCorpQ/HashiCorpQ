variable "name" {
  description = "Globally-unique S3 bucket name (lowercase, hyphens)."
  type        = string
}
variable "versioning" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}
variable "force_destroy" {
  description = "Allow destroy of a non-empty bucket. Keep FALSE in prod; TRUE only for ephemeral/learning buckets."
  type        = bool
  default     = false
}
variable "tags" {
  description = "Extra tags, merged over provider default_tags."
  type        = map(string)
  default     = {}
}
