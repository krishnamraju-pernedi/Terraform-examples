
output "dns_name" {
  value       = aws_elb.main-elb.dns_name
  description = "The domain name of the load balancer"
}