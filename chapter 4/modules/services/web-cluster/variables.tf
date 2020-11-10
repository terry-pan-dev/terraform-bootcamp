# ================== Variables ====================
variable "server_iport" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "server_oport" {
  description = "This port will allow all outbound requests"
  type        = number
  default     = 0
}

variable "cluster_name" {
  description = "The name to use for the cluster"
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the s3 bucket for the database's remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in s3"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to run"
  type        = string
}


variable "min_size" {
  description = "The minimum number of EC2 instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 instances in the ASG"
  type        = number
}


# ================== Data Source ====================
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_vpc_subnets" {
  vpc_id = data.aws_vpc.default_vpc.id
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "ap-southeast-2"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_iport
    db_address  = data.terraform_remote_state.db.outputs.db_address
    db_port     = data.terraform_remote_state.db.outputs.db_port
  }
}
