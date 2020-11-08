output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The arn for aws s3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.id
  description = "The dynamodb table name"
}
