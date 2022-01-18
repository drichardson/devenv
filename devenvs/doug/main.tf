terraform {
  backend "s3" {
    region = "us-west-2"

    bucket = "tfstate-devenv"
    key    = "devenvs/doug"

    dynamodb_table = "TerraformStateLock"
  }
}

provider "aws" {
  region = "us-west-1"

  default_tags {
    tags = {
      Terraform = "devenv-us-west-1"
      Name      = "dev-doug"
    }
  }
}

module "ami_picker" {
  source       = "../../modules/ami_pickers/debian"
  architecture = "x86_64"
}

module "devenv" {
  source         = "../../modules/devenv"
  ami            = module.ami_picker.ami
  ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcrrrk512HbXc04iyUdvzM9xAmPnWFWip7MG8sw6NuP"
}

output "address" {
  value = module.devenv.address
}

output "user" {
  value = module.ami_picker.username
}

output "instance_id" {
  description = "Developer instance ID."
  value       = module.devenv.instance_id
}

data "aws_region" "current" {}

output "stop-instance-command" {
  value = "aws ec2 stop-instances --region ${data.aws_region.current.name} --instance-ids ${module.devenv.instance_id}"
}

output "start-instance-command" {
  value = "aws ec2 start-instances --region ${data.aws_region.current.name} --instance-ids ${module.devenv.instance_id}"
}
