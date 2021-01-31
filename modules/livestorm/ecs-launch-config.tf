resource "aws_launch_configuration" "ecs_launch_config" {
  name_prefix                 = "ecs-${var.cluster_name}"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance.name
  image_id                    = data.aws_ami.ecs_instance.id
  instance_type               = var.ecs_instance_type
  security_groups             = [aws_security_group.ecs_instance_sg.id]
  user_data_base64            = base64encode(local.ecs_instance_userdata)
  key_name                    = var.key_name
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
