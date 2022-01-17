terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "tfstate-doug"
    region         = "us-west-2"
    dynamodb_table = "TerraformStateLock"

    key = "tfstate/devenv-us-west-2"
  }
}

provider "aws" {
  region = "us-west-1"

  default_tags {
    tags = {
      Terraform = "devenv-us-west-2"
    }
  }
}


module "devenv" {
  source = "../../modules/devenv"
}

