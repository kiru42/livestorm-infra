###################
##   RESSOURCES   #
###################

resource "aws_autoscaling_group" "ecs_asg" {
  name = local.common_tags["Name"]

  launch_configuration = aws_launch_configuration.ecs_launch_config.id
  health_check_type    = "ELB"

  min_size         = var.ecs_min_instances
  max_size         = var.ecs_max_instances
  desired_capacity = var.ecs_desired_capacity

  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.target_group.arn]
  wait_for_capacity_timeout = "10m"
  termination_policies      = ["OldestInstance"]

  tags = [
    {
      key                 = "AmazonECSManaged"
      value               = ""
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.common_tags["Name"]
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = local.common_tags["Environment"]
      propagate_at_launch = true
    },
  ]
}
