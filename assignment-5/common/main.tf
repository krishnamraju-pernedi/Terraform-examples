resource "aws_security_group" "ec2-sg" {
  name = "my-instance-SG"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb-sg" {
  name = "my elb-SG"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "ec2-config" {
  image_id        = var.ec2_image_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.ec2-sg.id]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {}
resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.ec2-config.id
  availability_zones   = data.aws_availability_zones.all.names
  min_size             = var.min_size
  max_size             = var.max_size

  load_balancers = [aws_elb.main-elb.name]

  health_check_type = "ELB"
}

resource "aws_elb" "main-elb" {
  name               = var.elb_name
  security_groups    = [aws_security_group.elb-sg.id]
  availability_zones = data.aws_availability_zones.all.names
  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}