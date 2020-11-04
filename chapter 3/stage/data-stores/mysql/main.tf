provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    key = "stage/data-stores/mysql/terraform.tfstate"
  }
}

resource "aws_db_instance" "example" {
  identifier_prefix         = "terraform-up-and-running"
  engine                    = "mysql"
  allocated_storage         = 10
  instance_class            = "db.t2.micro"
  name                      = "example_database"
  username                  = "admin"
  final_snapshot_identifier = "foo"

  password = var.db_password
}
