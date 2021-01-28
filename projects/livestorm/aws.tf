locals {
  name             = "livestorm"
  environment      = terraform.workspace
  resources_prefix = "${local.environment}-${local.name}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Let's create S3 bucket and dynamodb for storing tfstates and lock

module "livestorm-tf-states" {
  source = "../../modules/terraform-state"
  prefix = local.resources_prefix
}

# Create a custom VPC for our env

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws" # will be using the official terraform module
  version            = "2.66.0"
  name               = local.resources_prefix
  cidr               = "10.1.0.0/16"
  azs                = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets    = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets     = ["10.1.11.0/24", "10.1.12.0/24"]
  enable_nat_gateway = false

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}

# Create ECS module

module "ecs" {
  source             = "../../modules/ecs"
  name               = local.resources_prefix
  container_insights = true
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}

