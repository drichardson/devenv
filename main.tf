
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_key_pair" "devkey" {
  key_name = "dougpc-key"
  # TODO: Move to values
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGD/ZbEhEMrew8m5jlxxvdwiFhVaolo5y4974IOHc49l doug@DOUGPC@dougpc"
}
