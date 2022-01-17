output "ami" {
  description = "Amazon Linux 2 AMI"
  value       = data.aws_ami.amazon_linux_2
}

output "username" {
  description = "Default username of Amazon Linux 2 AMI"
  value       = "ec2-user"
}

