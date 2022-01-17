output "ami" {
  description = "Ubuntu AMI."
  value       = data.aws_ami.ubuntu
}

output "username" {
  description = "Ubuntu AMI username."
  value       = "ubuntu"
}
