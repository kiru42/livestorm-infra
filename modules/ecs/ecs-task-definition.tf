###################
##   RESSOURCES   #
###################

# default task definition (needed to create ECS service), then managed by CI/CD from github actions
resource "aws_ecs_task_definition" "ecs_service_task_definition" {
  family       = local.common_tags["Name"]
  network_mode = "bridge"

  container_definitions = <<EOF
[
  {
    "name": "${var.ecs_container_name}",
    "image": "managed_from_github_actions",
    "cpu": 128,
    "memoryReservation": 64,
    "portMappings": [
      {
        "hostPort": 0,
        "containerPort": ${var.ecs_service_port},
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
        "awslogs-group": "${aws_ecs_cluster.ecs_cluster.name}",
        "awslogs-stream-prefix": "${var.ecs_container_name}"
      }
    }
  }
]
EOF

  tags = local.common_tags
}
