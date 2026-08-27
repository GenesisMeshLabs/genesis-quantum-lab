terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Apply once per research/sandbox account (switch profile/role between runs,
# or duplicate this env directory per account — see src/terraform/README.md).
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "meta-quantum-harvest"
      ManagedBy = "terraform"
    }
  }
}
