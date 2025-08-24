module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  availability_zones = var.availability_zones
  enable_nat_gateway = false
  container_port     = var.container_port
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}

module "iam" {
  source = "./modules/iam"

  project_name          = var.project_name
  environment           = var.environment
  region                = var.region
  enable_github_actions = false
}

module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.networking.rds_security_group_id
  database_name         = var.database_name
  database_username     = var.database_username
  database_password     = var.database_password
  skip_final_snapshot   = true
}

module "s3_cloudfront" {
  source = "./modules/s3-cloudfront"

  project_name    = var.project_name
  environment     = var.environment
  allowed_origins = ["*"]
}

module "bastion" {
  count  = var.enable_bastion ? 1 : 0
  source = "./modules/bastion"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  key_pair_name     = var.key_pair_name
  rds_endpoint_host = split(":", module.rds.endpoint)[0]
  database_username = var.database_username
  database_name     = var.database_name
}

module "acm" {
  count  = var.enable_https ? 1 : 0
  source = "./modules/acm"

  project_name      = var.project_name
  environment       = var.environment
  domain_name       = var.domain_name
  root_domain_name  = var.root_domain_name
  alb_dns_name      = module.ecs.alb_dns_name
  alb_zone_id       = module.ecs.alb_zone_id
}

module "ec2_ecs" {
  count  = var.use_ec2 ? 1 : 0
  source = "./modules/ec2-ecs"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
  container_port        = var.container_port
  cluster_name          = module.ecs.cluster_name
  desired_capacity      = var.desired_count
  key_pair_name         = var.key_pair_name
}

module "ecs" {
  source = "./modules/ecs"

  project_name                 = var.project_name
  environment                  = var.environment
  region                       = var.region
  vpc_id                       = module.networking.vpc_id
  public_subnet_ids            = module.networking.public_subnet_ids
  private_subnet_ids           = module.networking.private_subnet_ids
  alb_security_group_id        = module.networking.alb_security_group_id
  ecs_tasks_security_group_id  = module.networking.ecs_tasks_security_group_id
  ecr_repository_url           = module.ecr.repository_url
  ecs_task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn            = module.iam.ecs_task_role_arn
  container_port               = var.container_port
  container_cpu                = var.container_cpu
  container_memory             = var.container_memory
  desired_count                = var.desired_count
  certificate_arn              = var.enable_https ? module.acm[0].certificate_arn : ""
  use_ec2                      = false
  ec2_capacity_provider_name   = var.use_ec2 ? module.ec2_ecs[0].capacity_provider_name : ""

  secrets = [
    # DATABASE_URL will be provided via SERVER_ENV environment variable instead
  ]
}