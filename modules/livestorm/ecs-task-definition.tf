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
