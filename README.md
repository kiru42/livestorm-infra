# LiveStorm on ECS

We are going to migrate LiveStorm on ECS.

LiveStorm is a highly available web application: responding `Hello world` on GET `/`

We will be creating the infrastruction on AWS using Terraform. 

# Requirements

We will be using :
- Terraform version : 0.14.5

# Infrastructure

We will create a Dockerfile with fixed terraform & providers versions for sharing the tools between DevOps instead of installing stuff locally.

For the purpose of this exercice, I will create an ECS module with all the required ressources.

In order to launch ou ECS, we need an VPC, we will use the following official module for this need :

- terraform-aws-modules/vpc/aws for creating VPC

These things are managed manually for testing purpose :

- Route53 public zone
- ACM certificate

Then we will configure a web application with github actions to build and deploy

# Running docker with infra tools

```bash
# let's build the docker with all tools

docker build -t livestorm-terraform-workspace .

docker run -it -v "$(pwd)":/livestorm -v "$(pwd)/.aws":/root/.aws livestorm-terraform-workspace bash
```

# Using terraform inside docker container

```bash
# for dev
terraform workspace new dev && terraform workspace select dev || terraform workspace select dev
terraform init && terraform plan
terraform apply # if everything seems fine to you
```

if you don't have access_key/secret_key configured for aws, you can open the following file (`provider.tf`) and copy paste this for testing the plan :

```tf
provider "aws" {
  region                      = "${var.region}"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_force_path_style         = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"

  endpoints {
    dynamodb = "http://localhost:4569"
    s3       = "http://localhost:4572"
  }
}
```

# Using workspace for different environment

```
terraform workspace new dev
terraform workspace new qa
terraform workspace new staging
terraform workspace new prod
terraform workspace select dev
```

# an Example of tf plan outputs

```tf
Terraform will perform the following actions:

  # module.ecs.aws_autoscaling_group.ecs_asg will be created
  + resource "aws_autoscaling_group" "ecs_asg" {
      + arn                       = (known after apply)
      + availability_zones        = (known after apply)
      + default_cooldown          = (known after apply)
      + desired_capacity          = 2
      + force_delete              = false
      + health_check_grace_period = 300
      + health_check_type         = "ELB"
      + id                        = (known after apply)
      + launch_configuration      = (known after apply)
      + max_size                  = 4
      + metrics_granularity       = "1Minute"
      + min_size                  = 2
      + name                      = "dev-livestorm-website"
      + protect_from_scale_in     = false
      + service_linked_role_arn   = (known after apply)
      + tags                      = [
          + {
              + "key"                 = "AmazonECSManaged"
              + "propagate_at_launch" = "true"
            },
          + {
              + "key"                 = "Cluster"
              + "propagate_at_launch" = "true"
              + "value"               = "dev-livestorm-website"
            },
          + {
              + "key"                 = "Environment"
              + "propagate_at_launch" = "true"
              + "value"               = "dev"
            },
        ]
      + target_group_arns         = (known after apply)
      + termination_policies      = [
          + "OldestInstance",
        ]
      + vpc_zone_identifier       = (known after apply)
      + wait_for_capacity_timeout = "10m"
    }

  # module.ecs.aws_cloudwatch_log_group.cloudwatch_log_group will be created
  + resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + name              = "dev-livestorm-website"
      + retention_in_days = 7
      + tags              = {
          + "Application" = "website"
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm-website"
          + "Project"     = "livestorm"
        }
    }

  # module.ecs.aws_ecr_repository.ecr will be created
  + resource "aws_ecr_repository" "ecr" {
      + arn                  = (known after apply)
      + id                   = (known after apply)
      + image_tag_mutability = "MUTABLE"
      + name                 = "dev-livestorm-website"
      + registry_id          = (known after apply)
      + repository_url       = (known after apply)
      + tags                 = {
          + "Application" = "website"
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm-website"
          + "Project"     = "livestorm"
        }

      + image_scanning_configuration {
          + scan_on_push = true
        }
    }

  # module.ecs.aws_ecs_capacity_provider.capacity_provider will be created
  + resource "aws_ecs_capacity_provider" "capacity_provider" {
      + arn  = (known after apply)
      + id   = (known after apply)
      + name = "dev-livestorm-website"

      + auto_scaling_group_provider {
          + auto_scaling_group_arn         = (known after apply)
          + managed_termination_protection = (known after apply)

          + managed_scaling {
              + maximum_scaling_step_size = (known after apply)
              + minimum_scaling_step_size = (known after apply)
              + status                    = (known after apply)
              + target_capacity           = (known after apply)
            }
        }
    }

  # module.ecs.aws_ecs_cluster.ecs_cluster will be created
  + resource "aws_ecs_cluster" "ecs_cluster" {
      + arn                = (known after apply)
      + capacity_providers = [
          + "FARGATE",
          + "FARGATE_SPOT",
          + "dev-livestorm-website",
        ]
      + id                 = (known after apply)
      + name               = "dev-livestorm-website"
      + tags               = {
          + "Application" = "website"
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm-website"
          + "Project"     = "livestorm"
        }

      + default_capacity_provider_strategy {
          + base              = 1
          + capacity_provider = "dev-livestorm-website"
          + weight            = 1
        }

      + setting {
          + name  = "containerInsights"
          + value = "enabled"
        }
    }

  # module.ecs.aws_ecs_service.ecs_service will be created
  + resource "aws_ecs_service" "ecs_service" {
      + cluster                            = (known after apply)
      + deployment_maximum_percent         = 200
      + deployment_minimum_healthy_percent = 100
      + desired_count                      = 10
      + enable_ecs_managed_tags            = false
      + iam_role                           = (known after apply)
      + id                                 = (known after apply)
      + launch_type                        = (known after apply)
      + name                               = "dev-livestorm-website"
      + platform_version                   = (known after apply)
      + scheduling_strategy                = "REPLICA"
      + tags                               = {
          + "Application" = "website"
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm-website"
          + "Project"     = "livestorm"
        }
      + task_definition                    = (known after apply)
      + wait_for_steady_state              = false

      + deployment_controller {
          + type = "ECS"
        }

      + load_balancer {
          + container_name   = "webapp"
          + container_port   = 3000
          + target_group_arn = (known after apply)
        }

      + ordered_placement_strategy {
          + field = "instanceId"
          + type  = "spread"
        }
    }

  # module.ecs.aws_ecs_task_definition.ecs_service_task_definition will be created
  + resource "aws_ecs_task_definition" "ecs_service_task_definition" {
      + arn                   = (known after apply)
      + container_definitions = jsonencode(
            [
              + {
                  + command           = [
                      + "./main",
                    ]
                  + cpu               = 128
                  + essential         = true
                  + image             = "managed_from_github_actions"
                  + logConfiguration  = {
                      + logDriver = "awslogs"
                      + options   = {
                          + awslogs-group         = "dev-livestorm-website"
                          + awslogs-region        = "eu-west-1"
                          + awslogs-stream-prefix = "webapp"
                        }
                    }
                  + memoryReservation = 64
                  + name              = "webapp"
                  + portMappings      = [
                      + {
                          + containerPort = 3000
                          + hostPort      = 0
                          + protocol      = "tcp"
                        },
                    ]
                },
            ]
        )
      + family                = "dev-livestorm-website"
      + id                    = (known after apply)
      + network_mode          = "bridge"
      + revision              = (known after apply)
      + tags                  = {
          + "Application" = "website"
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm-website"
          + "Project"     = "livestorm"
        }
    }

  # module.ecs.aws_iam_instance_profile.ecs_instance_profile will be created
  + resource "aws_iam_instance_profile" "ecs_instance_profile" {
      + arn         = (known after apply)
      + create_date = (known after apply)
      + id          = (known after apply)
      + name        = "dev-livestorm-website"
      + path        = "/"
      + role        = "dev-livestorm-website"
      + unique_id   = (known after apply)
    }

  # module.ecs.aws_iam_role.ecs_instance_role will be created
  + resource "aws_iam_role" "ecs_instance_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = [
                              + "ec2.amazonaws.com",
                            ]
                        }
                    },
                ]
              + Version   = "2008-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + max_session_duration  = 3600
      + name                  = "dev-livestorm-website"
      + path                  = "/ecs/"
      + tags                  = {
          + "Application" = "website"
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm-website"
          + "Project"     = "livestorm"
        }
      + unique_id             = (known after apply)
    }

  # module.ecs.aws_iam_role_policy_attachment.ecs_ec2_cloudwatch_role will be created
  + resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
      + role       = (known after apply)
    }

  # module.ecs.aws_iam_role_policy_attachment.ecs_ec2_role will be created
  + resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
      + role       = (known after apply)
    }

  # module.ecs.aws_key_pair.admin will be created
  + resource "aws_key_pair" "admin" {
      + arn         = (known after apply)
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + key_name    = "admin"
      + key_pair_id = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIkmHjisI8zyy4/38JUcYHi7C8YDU23Ussm3h6S9LSccMCQpmu3GW3czPeJYPOYZbus46B0ubsY3k73+0S4WsYSTYbQzUz1QeqiAwfF9HfWLiiF0zTC6myIq2hLQIJUvwXfK9Vhnv9Oi9VEqE7NiVAZoSXxwBBPv4hgv9DS1EK3RbvjlyvJvVdrTZQ1504q0xaz4xOt0YsrW+U4NkhlconZIx/9Ugm+dbcZ7STxruv5dAOLND8V0afkOtZR6iqqu2HEpRXohyMf48eh5kYxtH0NduYzBZK/c70TxXbR0hg8f7egX6enMpe6MlhFLgjOO8HkUX6mXy8JDw6DqpT/7M7 kiru42@gmail.com"
    }

  # module.ecs.aws_launch_configuration.ecs_launch_config will be created
  + resource "aws_launch_configuration" "ecs_launch_config" {
      + arn                         = (known after apply)
      + associate_public_ip_address = false
      + ebs_optimized               = false
      + enable_monitoring           = true
      + iam_instance_profile        = (known after apply)
      + id                          = (known after apply)
      + image_id                    = "ami-0de9fc0f891440ef7"
      + instance_type               = "t2.micro"
      + key_name                    = "admin"
      + name                        = (known after apply)
      + name_prefix                 = "dev-livestorm-website"
      + security_groups             = (known after apply)
      + user_data_base64            = "IyEvYmluL2Jhc2gKZWNobyAiRUNTX0NMVVNURVI9ZGV2LWxpdmVzdG9ybS13ZWJzaXRlIiA+PiAvZXRjL2Vjcy9lY3MuY29uZmlnCg=="

      + ebs_block_device {
          + delete_on_termination = true
          + device_name           = "/dev/xvdcz"
          + encrypted             = true
          + iops                  = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = true
          + encrypted             = true
          + iops                  = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # module.ecs.aws_lb.alb will be created
  + resource "aws_lb" "alb" {
      + arn                        = (known after apply)
      + arn_suffix                 = (known after apply)
      + dns_name                   = (known after apply)
      + drop_invalid_header_fields = false
      + enable_deletion_protection = false
      + enable_http2               = true
      + id                         = (known after apply)
      + idle_timeout               = 60
      + internal                   = false
      + ip_address_type            = (known after apply)
      + load_balancer_type         = "application"
      + name                       = "dev-livestorm-website"
      + security_groups            = (known after apply)
      + subnets                    = (known after apply)
      + tags                       = {
          + "Application" = "website"
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm-website"
          + "Project"     = "livestorm"
        }
      + vpc_id                     = (known after apply)
      + zone_id                    = (known after apply)

      + subnet_mapping {
          + allocation_id        = (known after apply)
          + outpost_id           = (known after apply)
          + private_ipv4_address = (known after apply)
          + subnet_id            = (known after apply)
        }
    }

  # module.ecs.aws_lb_listener.listener_http will be created
  + resource "aws_lb_listener" "listener_http" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 80
      + protocol          = "HTTP"
      + ssl_policy        = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # module.ecs.aws_lb_listener.listener_https will be created
  + resource "aws_lb_listener" "listener_https" {
      + arn               = (known after apply)
      + certificate_arn   = "arn:aws:acm:eu-west-1:002888593661:certificate/8a23f70c-4f58-4f6a-98cd-a19bbbded161"
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 443
      + protocol          = "HTTPS"
      + ssl_policy        = "ELBSecurityPolicy-2016-08"

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # module.ecs.aws_lb_target_group.target_group will be created
  + resource "aws_lb_target_group" "target_group" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + deregistration_delay               = 300
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "dev-livestorm-website"
      + port                               = 3000
      + protocol                           = "HTTP"
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags                               = {
          + "Application" = "website"
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm-website"
          + "Project"     = "livestorm"
        }
      + target_type                        = "instance"
      + vpc_id                             = (known after apply)

      + health_check {
          + enabled             = true
          + healthy_threshold   = 5
          + interval            = 30
          + matcher             = "200"
          + path                = "/"
          + port                = "traffic-port"
          + protocol            = "HTTP"
          + timeout             = 5
          + unhealthy_threshold = 2
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }
    }

  # module.ecs.aws_route53_record.service_public will be created
  + resource "aws_route53_record" "service_public" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "dev-livestorm.kiruban.fr"
      + type            = "A"
      + zone_id         = "Z10013643R0L0TLYMUOW8"

      + alias {
          + evaluate_target_health = false
          + name                   = (known after apply)
          + zone_id                = (known after apply)
        }
    }

  # module.ecs.aws_security_group.ecs will be created
  + resource "aws_security_group" "ecs" {
      + arn                    = (known after apply)
      + description            = "Security Group for ECS container instances"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 1
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = (known after apply)
              + self             = false
              + to_port          = 65535
            },
        ]
      + name                   = "dev-livestorm-website-ecs"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + vpc_id                 = (known after apply)
    }

  # module.ecs.aws_security_group.load_balancer will be created
  + resource "aws_security_group" "load_balancer" {
      + arn                    = (known after apply)
      + description            = "Security group for ALB"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "10.1.0.0/16",
                ]
              + description      = ""
              + from_port        = 1
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 65535
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
        ]
      + name                   = "dev-livestorm-website-loadbalancer"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + vpc_id                 = (known after apply)
    }

  # module.terraform-state.aws_dynamodb_table.terraform-state-lock will be created
  + resource "aws_dynamodb_table" "terraform-state-lock" {
      + arn              = (known after apply)
      + billing_mode     = "PROVISIONED"
      + hash_key         = "LockID"
      + id               = (known after apply)
      + name             = "dev-livestorm-website-terraform-state"
      + read_capacity    = 1
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Application" = "website"
          + "Component"   = "terraform-state"
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm-website-terraform-state"
          + "Project"     = "livestorm"
        }
      + write_capacity   = 1

      + attribute {
          + name = "LockID"
          + type = "S"
        }

      + point_in_time_recovery {
          + enabled = (known after apply)
        }

      + server_side_encryption {
          + enabled     = (known after apply)
          + kms_key_arn = (known after apply)
        }
    }

  # module.terraform-state.aws_s3_bucket.terraform-state will be created
  + resource "aws_s3_bucket" "terraform-state" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "dev-livestorm-website-terraform-state"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "Application" = "website"
          + "Component"   = "terraform-state"
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm-website-terraform-state"
          + "Project"     = "livestorm"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }
    }

  # module.vpc.aws_eip.nat[0] will be created
  + resource "aws_eip" "nat" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags                 = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
      + vpc                  = true
    }

  # module.vpc.aws_eip.nat[1] will be created
  + resource "aws_eip" "nat" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags                 = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
      + vpc                  = true
    }

  # module.vpc.aws_internet_gateway.this[0] will be created
  + resource "aws_internet_gateway" "this" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
      + vpc_id   = (known after apply)
    }

  # module.vpc.aws_nat_gateway.this[0] will be created
  + resource "aws_nat_gateway" "this" {
      + allocation_id        = (known after apply)
      + id                   = (known after apply)
      + network_interface_id = (known after apply)
      + private_ip           = (known after apply)
      + public_ip            = (known after apply)
      + subnet_id            = (known after apply)
      + tags                 = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
    }

  # module.vpc.aws_nat_gateway.this[1] will be created
  + resource "aws_nat_gateway" "this" {
      + allocation_id        = (known after apply)
      + id                   = (known after apply)
      + network_interface_id = (known after apply)
      + private_ip           = (known after apply)
      + public_ip            = (known after apply)
      + subnet_id            = (known after apply)
      + tags                 = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
    }

  # module.vpc.aws_route.private_nat_gateway[0] will be created
  + resource "aws_route" "private_nat_gateway" {
      + destination_cidr_block     = "0.0.0.0/0"
      + destination_prefix_list_id = (known after apply)
      + egress_only_gateway_id     = (known after apply)
      + gateway_id                 = (known after apply)
      + id                         = (known after apply)
      + instance_id                = (known after apply)
      + instance_owner_id          = (known after apply)
      + local_gateway_id           = (known after apply)
      + nat_gateway_id             = (known after apply)
      + network_interface_id       = (known after apply)
      + origin                     = (known after apply)
      + route_table_id             = (known after apply)
      + state                      = (known after apply)

      + timeouts {
          + create = "5m"
        }
    }

  # module.vpc.aws_route.private_nat_gateway[1] will be created
  + resource "aws_route" "private_nat_gateway" {
      + destination_cidr_block     = "0.0.0.0/0"
      + destination_prefix_list_id = (known after apply)
      + egress_only_gateway_id     = (known after apply)
      + gateway_id                 = (known after apply)
      + id                         = (known after apply)
      + instance_id                = (known after apply)
      + instance_owner_id          = (known after apply)
      + local_gateway_id           = (known after apply)
      + nat_gateway_id             = (known after apply)
      + network_interface_id       = (known after apply)
      + origin                     = (known after apply)
      + route_table_id             = (known after apply)
      + state                      = (known after apply)

      + timeouts {
          + create = "5m"
        }
    }

  # module.vpc.aws_route.public_internet_gateway[0] will be created
  + resource "aws_route" "public_internet_gateway" {
      + destination_cidr_block     = "0.0.0.0/0"
      + destination_prefix_list_id = (known after apply)
      + egress_only_gateway_id     = (known after apply)
      + gateway_id                 = (known after apply)
      + id                         = (known after apply)
      + instance_id                = (known after apply)
      + instance_owner_id          = (known after apply)
      + local_gateway_id           = (known after apply)
      + nat_gateway_id             = (known after apply)
      + network_interface_id       = (known after apply)
      + origin                     = (known after apply)
      + route_table_id             = (known after apply)
      + state                      = (known after apply)

      + timeouts {
          + create = "5m"
        }
    }

  # module.vpc.aws_route_table.private[0] will be created
  + resource "aws_route_table" "private" {
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table.private[1] will be created
  + resource "aws_route_table" "private" {
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table.public[0] will be created
  + resource "aws_route_table" "public" {
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = (known after apply)
      + tags             = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table_association.private[0] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.private[1] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public[0] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public[1] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_subnet.private[0] will be created
  + resource "aws_subnet" "private" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-west-1a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.1.1.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
      + vpc_id                          = (known after apply)
    }

  # module.vpc.aws_subnet.private[1] will be created
  + resource "aws_subnet" "private" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-west-1b"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.1.2.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = false
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
      + vpc_id                          = (known after apply)
    }

  # module.vpc.aws_subnet.public[0] will be created
  + resource "aws_subnet" "public" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-west-1a"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.1.11.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = true
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
      + vpc_id                          = (known after apply)
    }

  # module.vpc.aws_subnet.public[1] will be created
  + resource "aws_subnet" "public" {
      + arn                             = (known after apply)
      + assign_ipv6_address_on_creation = false
      + availability_zone               = "eu-west-1b"
      + availability_zone_id            = (known after apply)
      + cidr_block                      = "10.1.12.0/24"
      + id                              = (known after apply)
      + ipv6_cidr_block_association_id  = (known after apply)
      + map_public_ip_on_launch         = true
      + owner_id                        = (known after apply)
      + tags                            = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
      + vpc_id                          = (known after apply)
    }

  # module.vpc.aws_vpc.this[0] will be created
  + resource "aws_vpc" "this" {
      + arn                              = (known after apply)
      + assign_generated_ipv6_cidr_block = false
      + cidr_block                       = "10.1.0.0/16"
      + default_network_acl_id           = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_group_id        = (known after apply)
      + dhcp_options_id                  = (known after apply)
      + enable_classiclink               = (known after apply)
      + enable_classiclink_dns_support   = (known after apply)
      + enable_dns_hostnames             = false
      + enable_dns_support               = true
      + id                               = (known after apply)
      + instance_tenancy                 = "default"
      + ipv6_association_id              = (known after apply)
      + ipv6_cidr_block                  = (known after apply)
      + main_route_table_id              = (known after apply)
      + owner_id                         = (known after apply)
      + tags                             = {
          + "Environment" = "dev"
          + "Name"        = "dev-livestorm"
          + "Project"     = "livestorm"
        }
    }

Plan: 42 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```