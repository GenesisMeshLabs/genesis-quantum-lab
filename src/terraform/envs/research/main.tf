# Phase 2 root module — apply once per Research/Sandbox account.
# Deploys the segmented VPC described in 02-Cloud-Infrastructure.md.
# Set var.environment_name per account, e.g. "mqh-research-a", "mqh-sandbox".

module "networking" {
  source = "../../modules/networking"

  name = var.environment_name
  azs  = var.azs
  tags = { Phase = "2-lab-infrastructure", Environment = var.environment_name }
}

module "lab_app" {
  count  = var.deploy_lab_app ? 1 : 0
  source = "../../../app/infra"

  name                       = "${var.environment_name}-lab-app"
  vpc_id                     = module.networking.vpc_id
  public_subnet_ids          = module.networking.public_subnet_ids
  private_subnet_ids         = module.networking.private_subnet_ids
  alb_security_group_id      = module.networking.alb_security_group_id
  workload_security_group_id = module.networking.workload_security_group_id
  container_image            = var.container_image
  tags                       = { Phase = "2-3-lab-workloads", Environment = var.environment_name }
}
