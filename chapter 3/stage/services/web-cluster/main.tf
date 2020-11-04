# ================== Provider ====================
provider "aws" {
  region = "ap-southeast-2"
}

# ================== State server ====================

terraform {
  backend "s3" {
    key = "stage/services/web-cluster/terraform.tfstate"
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "terry-terraform-up-and-running-state"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

data "template_file" "user_data" {
  template = file("user-data.sh")

  vars = {
    server_port = var.server_iport
    db_address  = data.terraform_remote_state.db.outputs.db_address
    db_port     = data.terraform_remote_state.db.outputs.db_port
  }
}

# ================== Resource ====================
resource "aws_launch_configuration" "sample" {
  image_id        = "ami-099c1869f33464fde"
  instance_type   = "t2.micro"
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

resource "aws_autoscaling_group" "sample" {
  launch_configuration = aws_launch_configuration.sample.name
  # notice, vpc_zone_identifier requires a list, normally you need to add
  # brackets in front/end of the value parts. However, since the return
  # for data.aws_subnet_ids.default_vpc_subnets.ids is a list, we do not need
  # to add brackets.
  vpc_zone_identifier = data.aws_subnet_ids.default_vpc_subnets.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10
  tag {
    key                 = "Name"
    value               = "terraform-asg-sample"
    propagate_at_launch = true
  }
}

# An aws_load_balancer needs a listener(rules) to run
# also by default aws_load_balancer does not allow any
# incoming and out going traffic, thus we need another security group
resource "aws_lb" "sample" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default_vpc_subnets.ids
  security_groups    = [aws_security_group.elb.id]
}

# we have a listener attaches to a load_balancer. And also we need rules
# attach to this listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.sample.arn
  port              = 80
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

resource "aws_lb_listener_rule" "asg" {
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


resource "aws_security_group" "elb" {
  name = "terraform-sample-sg"

  # Allow inbound from HTTP requests
  ingress {
    from_port   = var.server_iport
    to_port     = var.server_iport
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = var.server_oport
    to_port     = var.server_oport
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# how does aws_lb_target_group knows which ec2 to send requests?
# aws_lb_target_group needs another resource called aws_lb_target_group_attachment
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-sample"
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
