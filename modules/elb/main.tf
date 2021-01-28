resource "aws_elb" "service" {
  subnets = var.subnet_ids
  security_groups = [
    aws_security_group.load_balancer.id
  ]

  internal = var.expose_to_public_internet == "yes" ? false : true

  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 60

  listener {
    instance_port      = var.service_port
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.service_certificate_arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = var.health_check_target
    interval            = 30
  }

  tags = {
    Name    = var.name
    Service = var.service_name
  }
}

resource "aws_route53_record" "service_public" {
  zone_id = var.public_zone_id
  name    = "${var.name}.${var.domain_name}"
  type    = "A"

  count = var.include_public_dns_record == "yes" ? 1 : 0

  alias {
    name                   = aws_elb.service.dns_name
    zone_id                = aws_elb.service.zone_id
    evaluate_target_health = false
  }
}

data "aws_vpc" "network" {
  id = var.vpc_id
}

resource "aws_security_group" "load_balancer" {
  name        = "${var.name}-elb"
  vpc_id      = var.vpc_id
  description = "ELB for ${var.name}"

  ingress {
    from_port   = 443
    to_port     = 443
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
  name        = "${var.name}-open-to-elb"
  vpc_id      = var.vpc_id
  description = "Open to ELB for ${var.name}"

  ingress {
    from_port = var.service_port
    to_port   = var.service_port
    protocol  = "tcp"
    security_groups = [
      aws_security_group.load_balancer.id
    ]
  }
}
