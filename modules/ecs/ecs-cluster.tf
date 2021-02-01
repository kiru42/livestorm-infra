###################
##   RESSOURCES   #
###################

# Capacity Provider
resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${local.common_tags["Name"]}-cp"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {

  name = "${local.common_tags["Name"]}-ecs"

  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
    weight            = 1
    base              = 1
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}
