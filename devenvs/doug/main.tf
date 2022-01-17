terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

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
  source       = "../../modules/ami_picker"
  architecture = "x86_64"
  distro       = "debian"
}

module "devenv" {
  source         = "../../modules/devenv"
  ami            = module.ami_picker.debian
  ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcrrrk512HbXc04iyUdvzM9xAmPnWFWip7MG8sw6NuP"
}

output "address" {
  value = module.devenv.address
}

output "user" {
  value = module.ami_picker.username
}

output "ssh" {
  description = "SSH connection string"
  value       = format("%s@%s", module.ami_picker.username, module.devenv.address)
}
