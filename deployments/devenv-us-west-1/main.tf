terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "doug-iac"
    key            = "tfstate/devenv-us-west-1"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock-table"
  }
}

module "devenv" {
  source = "../../modules/devenv"
  region = "us-west-1"
}

