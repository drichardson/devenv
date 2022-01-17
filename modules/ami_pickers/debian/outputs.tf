output "ami" {
  description = "Debian AMI"
  value       = data.aws_ami.debian
}

output "username" {
  description = "Debian AMI username"
  value       = "admin"
}
