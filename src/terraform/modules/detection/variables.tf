variable "config_bucket_name" {
  description = "S3 bucket name for AWS Config snapshots/history (separate from the CloudTrail audit bucket)."
  type        = string
}

variable "alert_email" {
  description = "Email address subscribed to the security alert SNS topic."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
