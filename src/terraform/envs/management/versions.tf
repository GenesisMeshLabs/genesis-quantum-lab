terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure once you have a state bucket (chicken-and-egg:
  # bootstrap once with local state, then migrate). See src/terraform/README.md.
  # backend "s3" {
  #   bucket         = "meta-quantum-harvest-tfstate"
  #   key            = "management/terraform.tfstate"
  #   region         = "eu-north-1"
  #   dynamodb_table = "meta-quantum-harvest-tflock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "meta-quantum-harvest"
      ManagedBy = "terraform"
    }
  }
}
