# ================== Provider ====================
provider "aws" {
  region = "ap-southeast-2"
}

# ================== State server ====================

terraform {
  backend "s3" {
    key = "modules/services/web-cluster/terraform.tfstate"
  }
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

# ================== Resource ====================
resource "aws_launch_configuration" "sample" {
  image_id        = "ami-099c1869f33464fde"
  instance_type   = var.instance_type
  security_groups = [aws_security_group.elb.id]

  user_data = data.template_file.user_data.rendered

  # since aws_autoscaling_group depends on this resource. Therefore, whenever,
  # there is any change on this resource. The normal procedure of terraform is
  # delete this resource then create a new one. However, after adding this 
  # lifecyle, terraform will create this resource first then update the
  # dependented resource accordingly. After all these actions succeed, 
  # terraform will delete the old resource.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.sample.name
  # notice, vpc_zone_identifier requires a list, normally you need to add
  # brackets in front/end of the value parts. However, since the return
  # for data.aws_subnet_ids.default_vpc_subnets.ids is a list, we do not need
  # to add brackets.
  vpc_zone_identifier = data.aws_subnet_ids.default_vpc_subnets.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size
  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}

# An aws_load_balancer needs a listener(rules) to run
# also by default aws_load_balancer does not allow any
# incoming and out going traffic, thus we need another security group
resource "aws_lb" "sample" {
  name               = "${var.cluster_name}-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default_vpc_subnets.ids
  security_groups    = [aws_security_group.elb.id]
}

# we have a listener attaches to a load_balancer. And also we need rules
# attach to this listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.sample.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "lb_listener_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}


resource "aws_security_group" "sg" {
  name = "${var.cluster_name}-sg"

  # Allow inbound from HTTP requests
  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  # Allow all outbound requests
  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.any_protocol
    cidr_blocks = local.all_ips
  }
}

# how does aws_lb_target_group knows which ec2 to send requests?
# aws_lb_target_group needs another resource called aws_lb_target_group_attachment
resource "aws_lb_target_group" "lb_target_group" {
  name     = "${var.cluster_name}-lb-target-group"
  port     = var.server_iport
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
    # send requests every 15 seconds
    interval = 15
    # if no response in 3 seconds, mark it as unhealthy
    timeout = 3
    # 2 consecutive healthy check means the target is health
    healthy_threshold = 2
    # 2 consecutive unhealthy check means the target is unhealth
    unhealthy_threshold = 2
  }
}
