# Phase 2 root module — apply once per Research/Sandbox account.
# Deploys the segmented VPC described in 02-Cloud-Infrastructure.md.
# Set var.environment_name per account, e.g. "mqh-research-a", "mqh-sandbox".

module "networking" {
  source = "../../modules/networking"

  name = var.environment_name
  azs  = var.azs
  tags = { Phase = "2-lab-infrastructure", Environment = var.environment_name }
}
