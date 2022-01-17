output "amazon_linux_2" {
  description = "Amazon Linux 2 AMI ID"
  value       = data.aws_ami.amazon_linux_2
}

output "debian" {
  description = "Debian AMI ID"
  value       = data.aws_ami.debian
}

output "ubuntu" {
  description = "Ubuntu AMI ID"
  value       = data.aws_ami.ubuntu
}
