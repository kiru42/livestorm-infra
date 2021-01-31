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
