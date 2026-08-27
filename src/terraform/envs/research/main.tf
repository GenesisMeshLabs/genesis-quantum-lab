# Phase 2 root module — apply once per Research/Sandbox account.
# Deploys the segmented VPC described in 02-Cloud-Infrastructure.md.
# Set var.environment_name per account, e.g. "mqh-research-a", "mqh-sandbox".

module "networking" {
  source = "../../modules/networking"

  name                    = var.environment_name
  azs                     = var.azs
  enable_network_firewall = var.enable_network_firewall
  tags                    = { Phase = "2-lab-infrastructure", Environment = var.environment_name }
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

module "database" {
  count  = var.deploy_test_database ? 1 : 0
  source = "../../modules/database"

  name                       = var.environment_name
  vpc_id                     = module.networking.vpc_id
  private_subnet_ids         = module.networking.private_subnet_ids
  allowed_security_group_ids = [module.networking.workload_security_group_id]
  tags                       = { Phase = "2-lab-infrastructure", Environment = var.environment_name }
}

module "dashboard" {
  count  = var.deploy_dashboard ? 1 : 0
  source = "../../modules/dashboards"

  name   = var.environment_name
  region = var.aws_region

  flow_log_group_name           = module.networking.flow_log_group_name
  firewall_alert_log_group_name = module.networking.network_firewall_alert_log_group_name

  alb_arn_suffix   = var.deploy_lab_app ? module.lab_app[0].alb_arn_suffix : null
  ecs_cluster_name = var.deploy_lab_app ? module.lab_app[0].ecs_cluster_name : null
  ecs_service_name = var.deploy_lab_app ? module.lab_app[0].ecs_service_name : null

  rds_instance_id = var.deploy_test_database ? module.database[0].db_instance_id : null
}
