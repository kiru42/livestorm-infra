resource "aws_cloudwatch_log_group" "ecs_service_cloudwatch_log_group" {
  name              = var.name
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "ecs_service_task_definition" {
  family = var.name

  container_definitions = <<EOF
[
  {
    "name": "${var.name}",
    "image": "${var.name}",
    "cpu": 128,
    "memory": 128,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${var.name}",
        "awslogs-stream-prefix": "complete-ecs"
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

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
