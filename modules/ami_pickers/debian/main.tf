# https://wiki.debian.org/Cloud/AmazonEC2Image/
# https://aws.amazon.com/marketplace/seller-profile?id=4d4d4e5f-c474-49f2-8b18-94de9d43e2c0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "aws_ami" "debian" {
  executable_users = ["all"]
  most_recent      = true
  owners           = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-11-*"]
  }

  filter {
    name   = "architecture"
    values = [var.architecture]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "ena-support"
    values = [true]
  }
}

