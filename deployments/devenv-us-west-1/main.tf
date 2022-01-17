terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "tfstate-doug"
    key            = "tfstate/devenv-us-west-1"
    region         = "us-west-2"
    dynamodb_table = "TerraformStateLock"
  }
}

provider "aws" {
  region = "us-west-1"

  default_tags {
    tags = {
      Terraform = "devenv-us-west-1"
    }
  }
}

module "devenv" {
  source = "../../modules/devenv"
}

