provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

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
  image_id        = "ami-830c94e3"
  instance_type   = "t2.micro"
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
  min_size             = 1
  max_size             = 2

  load_balancers    = [aws_elb.main-elb.name]

  health_check_type = "ELB"
}

resource "aws_elb" "main-elb" {
  name               = "krishna-app"
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
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

output "dns_name" {
  value       = aws_elb.main-elb.dns_name
  description = "The domain name of the load balancer"
}