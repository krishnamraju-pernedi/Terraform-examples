provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

resource "aws_security_group" "instance-sg" {
  name = "my-SG-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "krishna-app" {
  ami                    = "ami-830c94e3"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = {
    "Name" = "ec2_instance"
  }
}

output "public_ip" {
  value       = aws_instance.krishna-app.public_ip
  description = "The public IP of the web server"
}
output "public_dns" {
  value       = aws_instance.krishna-app.public_dns
  description = "The public Ipublic_dnsP of the web server"
}