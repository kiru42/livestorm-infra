# Project
project     = "livestorm"
application = "website"
region      = "eu-west-1"

## VPC
cidr            = "10.1.0.0/16"
public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]
private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]

# ECS
ecs_min_instances    = 2
ecs_max_instances    = 4
ecs_desired_capacity = 2
ecs_instance_type    = "t2.micro"
ecs_container_name   = "webapp"
ecs_service_port     = 3000

# Route53
public_zone_id = "Z10013643R0L0TLYMUOW8"
domain_name    = "kiruban.fr"

# ACM
acm_arn        = "arn:aws:acm:eu-west-1:002888593661:certificate/8a23f70c-4f58-4f6a-98cd-a19bbbded161"

# ALB 
allowed_cidrs_for_alb = ["0.0.0.0/0"]