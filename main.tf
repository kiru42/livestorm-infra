data "aws_availability_zones" "available" {
  state = "available"
}

#################
#     MODULES   #
#################

# Let's create S3 bucket and dynamodb for storing tfstates and lock

module "terraform-state" {
  source      = "./modules/terraform-state"
  project     = var.project
  application = var.application
}

# Create a custom VPC for our env from terraform official VPC module

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "2.66.0"
  name               = "${terraform.workspace}-${var.project}-${var.application}-vpc"
  cidr               = var.cidr
  azs                = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  enable_nat_gateway = true

  tags = {
    Name        = "${terraform.workspace}-${var.project}-${var.application}-vpc"
    Environment = terraform.workspace
    Project     = var.project
    Application = var.application
  }
}

########### LIVESTORM ECS cluster

module "ecs" {
  source = "./modules/ecs"

  # PROJECT
  project     = var.project
  application = var.application
  region      = var.region

  # VPC
  vpc_id             = module.vpc.vpc_id
  cidr               = module.vpc.vpc_cidr_block
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets

  # ECS
  ecs_min_instances    = var.ecs_min_instances
  ecs_max_instances    = var.ecs_max_instances
  ecs_desired_capacity = var.ecs_desired_capacity
  ecs_instance_type    = var.ecs_instance_type
  ecs_container_name   = var.ecs_container_name
  ecs_service_port     = var.ecs_service_port

  # ROUTE53
  public_zone_id = var.public_zone_id
  domain_name    = var.domain_name

  # ACM
  acm_arn = var.acm_arn

  # ALB
  allowed_cidrs_for_alb = var.allowed_cidrs_for_alb
}
