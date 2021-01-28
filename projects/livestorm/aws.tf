#################
#     LOCALS    #
#################

locals {
  name             = "livestorm"
  environment      = terraform.workspace
  instance_type    = "t2.micro"
  resources_prefix = "${local.environment}-${local.name}"
}

#################
#     DATAS     #
#################

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    cluster_name = local.name
  }
}

####################
#     RESSOURCES   #
####################

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = local.resources_prefix
  auto_scaling_group_provider {
    auto_scaling_group_arn = module.asg.this_autoscaling_group_arn
  }
}

#################
#     MODULES   #
#################

# Let's create S3 bucket and dynamodb for storing tfstates and lock

module "livestorm-tf-states" {
  source = "../../modules/terraform-state"
  prefix = local.resources_prefix
}

# Create a custom VPC for our env from terraform official VPC module

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
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

# Create ECS along ECR repository from our own module

module "ecs" {
  source             = "../../modules/ecs"
  name               = local.resources_prefix
  container_insights = true
  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.capacity_provider.name]
  default_capacity_provider_strategy = [
    {
      capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
    }
  ]

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}

# Create Auto Scaling Group from official ASG module

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "3.8.0"
  name    = local.resources_prefix
  lc_name = local.resources_prefix # Launch Config

  image_id             = data.aws_ami.amazon_linux_ecs.id
  instance_type        = local.instance_type
  security_groups      = [module.vpc.default_security_group_id]
  iam_instance_profile = module.ecs.ecs_iam_instance_profile_id
  user_data            = data.template_file.user_data.rendered

  # Auto scaling group
  asg_name                  = local.resources_prefix
  vpc_zone_identifier       = module.vpc.private_subnets
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 10
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Cluster"
      value               = local.name
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = local.environment
      propagate_at_launch = true
    },
  ]
}
