resource "aws_cloudwatch_log_group" "ecs_service_cloudwatch_log_group" {
  name              = var.name
  retention_in_days = 1
}
