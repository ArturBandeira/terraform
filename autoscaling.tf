data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "lt-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type

  network_interfaces {
    security_groups            = [aws_security_group.app.id]
    associate_public_ip_address = false
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name          = "app-server"
      Owner         = var.owner_tag
      AMBIENTE      = var.ambiente
      RESPONSAVEL   = var.responsavel
      SCHEDULE      = var.schedule
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "asg-app"
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [for s in aws_subnet.app : s.id]
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Owner"
    value               = var.owner_tag
    propagate_at_launch = true
  }

  tag {
    key                 = "AMBIENTE"
    value               = var.ambiente
    propagate_at_launch = true
  }

  tag {
    key                 = "RESPONSAVEL"
    value               = var.responsavel
    propagate_at_launch = true
  }

  tag {
    key                 = "SCHEDULE"
    value               = var.schedule
    propagate_at_launch = true
  }
}
