
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "doug-iac"
    key    = "tfstate/devenv"
    region = "us-west-2"
  }
}

module "devenv1" {
  source = "./modules/devenv"

  region = "us-west-1"

  tags = {
    Environment = "developer"
    Developer   = "doug"
  }
}
