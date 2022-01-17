locals {

  # https://ubuntu.com/server/docs/cloud-images/amazon-ec2
  # https://aws.amazon.com/marketplace/seller-profile?id=565feec9-3d43-413e-9760-c651546613f2
  canonical_aws_account_id = "099720109477"

  # https://wiki.debian.org/Cloud/AmazonEC2Image/
  # https://aws.amazon.com/marketplace/seller-profile?id=4d4d4e5f-c474-49f2-8b18-94de9d43e2c0
  debian_aws_account_id = "136693071363"
}

data "aws_ami" "amazon_linux_2" {
  executable_users = ["all"]
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
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

data "aws_ami" "debian" {
  executable_users = ["all"]
  most_recent      = true
  owners           = [local.debian_aws_account_id]

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

data "aws_ami" "ubuntu" {
  executable_users = ["all"]
  most_recent      = true
  owners           = [local.canonical_aws_account_id]

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-hirsute-*"]
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

