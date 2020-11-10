provider "aws" {
  region = "ap-southeast-2"
}

module "web_cluster" {
  source = "../../../modules/services/web-cluster"

  cluster_name           = "webservers-stage-env"
  db_remote_state_bueckt = "terry-terraform-up-and-running-state"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
}
