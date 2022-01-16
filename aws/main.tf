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

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Environment = "developer"
      Developer   = "doug"
    }
  }
}

resource "aws_key_pair" "dev" {
  key_name_prefix = "dev"
  public_key      = file("~/.ssh/id_ed25519.pub")
}

resource "aws_vpc" "dev" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "dev" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "172.16.0.0/24"
}

resource "aws_network_interface" "dev" {
  subnet_id   = aws_subnet.dev.id
  private_ips = ["172.16.0.1"]
}

data "aws_ami" "dev" {
  executable_users = ["self"]
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
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
    name   = "block_device_mappings.ebs.volume_type"
    values = ["gp2"]
  }
}

resource "aws_ebs_volume" "dev" {
  availability_zone = "us-west-2a"
  type              = "gp3"

  encrypted = true

  # gp3 volumes can be provisioned with different throughput (125-1000 MiB/s)
  # and iops (3000-16000), but there is a relationship requirement between
  # size, throughput, and iops.
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html
  size       = 10
  throughput = 125
  iops       = 3000
}

# TODO
# Security Group
# Elastic IP aws_eip
# Routing

resource "aws_instance" "dev" {
  # t4g.xlarge - 4vCPU, 16GiB arm64 $0.1344
  # t3a.xlarge - 4VCPU, 16GiB x86_64 AMD $0.1504
  # t3.xlarge - 4VCPU, 16GiB x86_64 Intel $0.1664

  ami           = data.aws_ami.dev.id
  instance_type = "t3g.xlarge"

  key_name = aws_key_pair.dev.id

  associate_public_ip_address = true

  ebs_optimized = true

  network_interface {
    network_interface_id = aws_network_interface.dev.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}

resource "aws_volume_attachment" "dev" {
  device_name = "/dev/xvdb"
  volume_id   = aws_ebs_volume.dev.id
  instance_id = aws_instance.dev.id
}
