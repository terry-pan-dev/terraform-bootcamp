output "db_address" {
  value       = aws_db_instance.example.address
  description = "The endpoint of mysql database"
}

output "db_port" {
  value       = aws_db_instance.example.port
  description = "The port of endpoint of mysql database"
}
