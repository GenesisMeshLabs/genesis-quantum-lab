variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "environment_name" {
  description = "e.g. 'mqh-research-a', 'mqh-sandbox'"
  type        = string
}

variable "azs" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "deploy_lab_app" {
  description = "Whether to deploy the synthetic lab app (src/app/web) onto ECS Fargate in this account. Requires container_image to be set to a built/pushed image."
  type        = bool
  default     = false
}

variable "container_image" {
  description = "ECR image URI for the lab app, e.g. '<account>.dkr.ecr.eu-north-1.amazonaws.com/mqh-lab-app:latest'."
  type        = string
  default     = ""
}

variable "enable_network_firewall" {
  description = "Deploy AWS Network Firewall in the inspection tier with a domain allow-list, and route private-subnet egress through it."
  type        = bool
  default     = false
}

variable "deploy_test_database" {
  description = "Deploy the RDS test database (synthetic data only) for this research account."
  type        = bool
  default     = false
}

variable "deploy_dashboard" {
  description = "Deploy a CloudWatch dashboard summarizing this account's network/app/db signals."
  type        = bool
  default     = true
}
