terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Terraform = "bootstrap"
    }
  }
}

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = "tfstate-doug"
  acl    = "private"
}

resource "aws_dynamodb_table" "tfstate_lock_table" {
  name = "TerraformStateLock"

  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

