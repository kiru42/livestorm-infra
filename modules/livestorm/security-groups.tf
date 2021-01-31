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
    cidr_blocks = list(data.aws_vpc.network.cidr_block)
  }
}

resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs"
  vpc_id      = var.vpc_id
  description = "Security Group for ${var.name} ECS container instance"

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
