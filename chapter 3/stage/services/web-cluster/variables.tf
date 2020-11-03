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

# ================== Data Source ====================
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_vpc_subnets" {
  vpc_id = data.aws_vpc.default_vpc.id
}
