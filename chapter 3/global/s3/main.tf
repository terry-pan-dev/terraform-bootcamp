provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "terraform_state" {
  # the bucket name must be globally unique. Hence, you need to change to an
  # proper name
  bucket = "terry-terraform-up-and-running-state"

  # by setting this lifecycle prevent_destroy to true, when you run
  # terraform destroy it will cause terraform to exit with an error.
  # since this is a bootcamp, there is no need to using this lifecycle
  # However, in a production environment, generally this is a good practice
  #   lifecycle {
  #     prevent_destroy = true
  #   }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terry-terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
