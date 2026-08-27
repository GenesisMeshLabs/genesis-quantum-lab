terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Apply this configuration with credentials/role for the Security member
# account (e.g. via `role_arn` assume-role into OrganizationAccountAccessRole,
# or an AWS SSO profile scoped to that account). See src/terraform/README.md.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "meta-quantum-harvest"
      ManagedBy = "terraform"
      Account   = "security"
    }
  }
}
