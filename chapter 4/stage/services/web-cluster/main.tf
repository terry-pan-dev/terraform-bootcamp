provider "aws" {
  region = "ap-southeast-2"
}

module "web_cluster" {
  source = "../../../modules/services/web-cluster"
}
