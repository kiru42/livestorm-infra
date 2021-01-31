locals {
  component = "alb"
  common_tags = {
    Name        = "${terraform.workspace}-${var.project}-${var.application}-${local.component}"
    Environment = terraform.workspace
    Project     = var.project
    Application = var.application
    Component   = local.component
  }
}

# Create ALB
resource "aws_lb" "alb" {
  name    = local.common_tags["Name"]
  subnets = var.public_subnet_ids
  security_groups = [
    aws_security_group.load_balancer.id
  ]

  internal = false

  tags = local.common_tags
}

# Create Target Group
resource "aws_lb_target_group" "target_group" {
  name        = var.name
  port        = var.service_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200"
  }
}

# Create HTTP Listener
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}

# Create HTTPS Listener
resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.service_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}
