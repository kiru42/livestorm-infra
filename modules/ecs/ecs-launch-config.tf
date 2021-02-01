###################
##      DATA      #
###################

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    cluster_name = "${local.common_tags["Name"]}-ecs"
  }
}

###################
##   RESSOURCES   #
###################

resource "aws_launch_configuration" "ecs_launch_config" {
  name_prefix                 = "${local.common_tags["Name"]}-lc"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.id
  image_id                    = data.aws_ami.amazon_linux_ecs.id
  instance_type               = var.ecs_instance_type
  security_groups             = [aws_security_group.ecs.id]
  user_data_base64            = base64encode(data.template_file.user_data.rendered)
  key_name                    = aws_key_pair.admin.key_name
  ebs_optimized               = false

  root_block_device {
    delete_on_termination = true
    encrypted             = true
  }

  ebs_block_device {
    device_name = "/dev/xvdcz"
    encrypted   = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
