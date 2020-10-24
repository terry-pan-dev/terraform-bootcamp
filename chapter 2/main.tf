provider "aws" {
  region = "ap-southeast-2"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

resource "aws_security_group" "sample" {
  name = "terraform-sample-sg"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sample" {
  ami                    = "ami-099c1869f33464fde"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sample.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "hello world" > index.html
  nohup busybox httpd -f -p ${var.server_port} &
  EOF

  tags = {
    "Name" = "terraform-sample"
  }
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_vpc_subnets" {
  vpc_id = data.aws_vpc.default_vpc.id
}


output "ec2_public_dns" {
  description = "The public domain name for sample ec2 instance"
  value       = aws_instance.sample.public_dns
}

output "ec2_public_ip" {
  description = "The public ip address for sample ec2 instance"
  value       = aws_instance.sample.public_ip
}
