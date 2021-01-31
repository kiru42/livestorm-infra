locals {
  container_name = "${var.name}-${var.container_name}"
}

resource "aws_cloudwatch_log_group" "ecs_service_cloudwatch_log_group" {
  name              = var.name
  retention_in_days = 1
}

# default task definition (needed to create ECS service), then managed by CI/CD from github actions

resource "aws_ecs_task_definition" "ecs_service_task_definition" {
  family       = var.name
  network_mode = "bridge"

  container_definitions = <<EOF
[
  {
    "name": "${local.container_name}",
    "image": "managed_from_github_actions",
    "cpu": 128,
    "memoryReservation": 64,
    "portMappings": [
      {
        "hostPort": 0,
        "containerPort": 3000,
        "protocol": "tcp"
      }
    ],
    "command": [
      "./main"
    ],
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${var.name}",
        "awslogs-stream-prefix": "${var.container_name}"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "ecs_service_main" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.ecs_service_task_definition.arn

  desired_count                      = 10
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  ordered_placement_strategy {
    type  = "spread"
    field = "host"
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = local.container_name
    container_port   = 3000
  }

  deployment_controller {
    type = "ECS"
  }

  # after the first deployment these parameters are managed from ECS and/or github actions deployment, so we need to ignore changes
  lifecycle {
    ignore_changes = [task_definition, capacity_provider_strategy]
  }

}
