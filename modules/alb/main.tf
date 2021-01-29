# Create ALB
resource "aws_lb" "alb" {
  name    = var.name
  subnets = var.subnet_ids
  security_groups = [
    aws_security_group.load_balancer.id
  ]

  internal = var.expose_to_public_internet == "yes" ? false : true

  tags = {
    Name    = var.name
    Service = var.service_name
  }
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

resource "aws_route53_record" "service_public" {
  zone_id = var.public_zone_id
  name    = "${var.name}.${var.domain_name}"
  type    = "A"

  count = var.include_public_dns_record == "yes" ? 1 : 0

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}

data "aws_vpc" "network" {
  id = var.vpc_id
}

resource "aws_security_group" "load_balancer" {
  name        = "${var.name}-alb"
  vpc_id      = var.vpc_id
  description = "ALB SG for ${var.name}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allow_cidrs
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allow_cidrs
  }

  egress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = coalescelist(var.egress_cidrs, list(data.aws_vpc.network.cidr_block))
  }
}

resource "aws_security_group" "open_to_load_balancer" {
  name        = "${var.name}-open-to-alb"
  vpc_id      = var.vpc_id
  description = "Open to ALB for ${var.name}"

  ingress {
    from_port = var.service_port
    to_port   = var.service_port
    protocol  = "tcp"
    security_groups = [
      aws_security_group.load_balancer.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
