output "address" {
  description = "IP address of developer instance."
  value       = aws_instance.dev.public_ip
}

output "instance_id" {
  description = "AWS Instance ID."
  value       = aws_instance.dev.id
}
