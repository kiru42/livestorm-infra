
resource "aws_autoscaling_group" "ecs" {
  depends_on                = [aws_ecs_cluster.ecs]
  name                      = "ecs-${var.cluster_name}"
  desired_capacity          = var.ecs_instance_num
  launch_configuration      = aws_launch_configuration.ecs_launch_config.id
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = var.ecs_max_instances
  vpc_zone_identifier       = [for subnet in data.aws_subnet_ids.private.ids : subnet]
  target_group_arns         = [aws_lb_target_group.ecs-ingress-http.arn]
  wait_for_capacity_timeout = "10m"
  termination_policies      = ["OldestInstance"]
}
