#################
#     LOCALS    #
#################

locals {
  name             = "livestorm"
  environment      = terraform.workspace
  instance_type    = "t2.micro"
  resources_prefix = "${local.environment}-${local.name}"
  region           = "eu-west-1"

  ## VPC related
  cidr            = "10.1.0.0/16"
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]

  # Domain related stuff (for testing purpose)
  public_zone_id = "Z10013643R0L0TLYMUOW8"
  domain_name    = "kiruban.fr"
  acm_arn        = "arn:aws:acm:eu-west-1:002888593661:certificate/8a23f70c-4f58-4f6a-98cd-a19bbbded161"

  # App details
  service_port = 3000

  # ALB releted
  allowed_cidrs_for_alb = ["0.0.0.0/0"]
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
    cluster_name = local.resources_prefix
  }
}

####################
#     RESSOURCES   #
####################

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = local.resources_prefix
  auto_scaling_group_provider {
    auto_scaling_group_arn = module.asg.this_autoscaling_group_arn
    # managed_scaling {
    #   maximum_scaling_step_size = 1000
    #   minimum_scaling_step_size = 1
    #   status                    = "ENABLED"
    #   target_capacity           = 10
    # }
  }
}

resource "aws_key_pair" "admin" {
  key_name   = "admin"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIkmHjisI8zyy4/38JUcYHi7C8YDU23Ussm3h6S9LSccMCQpmu3GW3czPeJYPOYZbus46B0ubsY3k73+0S4WsYSTYbQzUz1QeqiAwfF9HfWLiiF0zTC6myIq2hLQIJUvwXfK9Vhnv9Oi9VEqE7NiVAZoSXxwBBPv4hgv9DS1EK3RbvjlyvJvVdrTZQ1504q0xaz4xOt0YsrW+U4NkhlconZIx/9Ugm+dbcZ7STxruv5dAOLND8V0afkOtZR6iqqu2HEpRXohyMf48eh5kYxtH0NduYzBZK/c70TxXbR0hg8f7egX6enMpe6MlhFLgjOO8HkUX6mXy8JDw6DqpT/7M7 kiru42@gmail.com"
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
  cidr               = local.cidr
  azs                = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets    = local.private_subnets
  public_subnets     = local.public_subnets
  enable_nat_gateway = true

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
      weight            = 100
    }
  ]

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}

# Create Auto Scaling Group from official ASG module

module "asg" {
  source            = "terraform-aws-modules/autoscaling/aws"
  version           = "3.8.0"
  name              = local.resources_prefix
  lc_name           = local.resources_prefix # Launch Config
  target_group_arns = [module.alb.target_group_arn]

  image_id             = data.aws_ami.amazon_linux_ecs.id
  instance_type        = local.instance_type
  security_groups      = [module.vpc.default_security_group_id]
  iam_instance_profile = module.ecs.ecs_iam_instance_profile_id
  user_data            = data.template_file.user_data.rendered
  key_name             = aws_key_pair.admin.key_name

  # Auto scaling group
  asg_name                  = local.resources_prefix
  vpc_zone_identifier       = module.vpc.private_subnets
  health_check_type         = "ELB"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "AmazonECSManaged"
      value               = ""
      propagate_at_launch = true
    },
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

# Create ECS Service for livestorm along default task definition

module "hello_world" {
  source           = "../../modules/ecs-service"
  region           = local.region
  name             = local.resources_prefix
  cluster_id       = module.ecs.ecs_cluster_id
  target_group_arn = module.alb.target_group_arn
}

# Creating ALB for ECS

module "alb" {
  source = "../../modules/alb"

  name       = local.resources_prefix
  region     = local.region
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  service_name            = local.name
  service_port            = local.service_port
  service_certificate_arn = local.acm_arn

  domain_name    = local.domain_name
  public_zone_id = local.public_zone_id

  health_check_target = "HTTP:${local.service_port}/"

  allow_cidrs = local.allowed_cidrs_for_alb

  include_public_dns_record = "yes"
  expose_to_public_internet = "yes"
}
