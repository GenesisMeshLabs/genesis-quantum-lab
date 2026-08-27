variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "audit_bucket_name" {
  description = "Globally-unique S3 bucket name for the immutable CloudTrail audit log."
  type        = string
}

variable "config_bucket_name" {
  description = "Globally-unique S3 bucket name for AWS Config snapshots."
  type        = string
}

variable "alert_email" {
  description = "Email that receives GuardDuty/security alerts."
  type        = string
}
