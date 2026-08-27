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
