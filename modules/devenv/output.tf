output "address" {
  description = "IP address of developer instance."
  value       = aws_instance.dev.public_ip
}

