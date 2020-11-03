output "alb_dns_name" {
  value       = aws_lb.sample.dns_name
  description = "The public domain name for load balancer"
}
