terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    region = "us-west-2"

    bucket = "tfstate-doug"
    key    = "tfstate/devenv-eu-central-1"

    dynamodb_table = "TerraformStateLock"
  }
}

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Terraform = "devenv-eu-central-1"
    }
  }
}

module "devenv" {
  source         = "../../modules/devenv"
  architecture   = "arm64"
  ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcrrrk512HbXc04iyUdvzM9xAmPnWFWip7MG8sw6NuP"
}

output "address" {
  value = module.devenv.address
}
