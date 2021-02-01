resource "aws_security_group" "load_balancer" {
  name        = "${local.common_tags["Name"]}-sg-alb"
  vpc_id      = var.vpc_id
  description = "Security group for ALB"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs_for_alb
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs_for_alb
  }

  egress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = list(var.cidr)
  }
}

resource "aws_security_group" "ecs" {
  name        = "${local.common_tags["Name"]}-sg-ecs"
  vpc_id      = var.vpc_id
  description = "Security Group for ECS container instances"

  ingress {
    from_port = 1
    to_port   = 65535
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
