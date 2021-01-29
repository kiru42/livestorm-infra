resource "aws_cloudwatch_log_group" "ecs_service_cloudwatch_log_group" {
  name              = var.name
  retention_in_days = 7
}

resource "aws_ecs_service" "ecs_service_main" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = var.name

  desired_count = 10

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 50

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.name
    container_port   = 3000
  }

  deployment_controller {
    type = "ECS"
  }

}
