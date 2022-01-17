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

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "dev" {
  count             = 4
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "172.16.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
}

resource "aws_security_group" "dev" {
  name_prefix = "dev"
  description = "Developer instance security group."
  vpc_id      = aws_vpc.dev.id

  ingress {
    # From port and to port for ICMP from
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-security-group-ingress.html
    description      = "Ping from Anywhere"
    from_port        = 8
    to_port          = 0
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from Anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_network_interface" "dev" {
  subnet_id       = aws_subnet.dev[0].id
  security_groups = [aws_security_group.dev.id]
}


data "aws_ami" "dev" {
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
}

resource "aws_ebs_volume" "dev" {
  availability_zone = local.instance_availability_zone
  encrypted         = true
  type              = "gp3"

  # gp3 volumes can be provisioned with different throughput (125-1000 MiB/s)
  # and iops (3000-16000), but there is a relationship requirement between
  # size, throughput, and iops.
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html
  size       = 10
  throughput = 125
  iops       = 3000
}

# TODO
# Routing

locals {
  # t4g.xlarge - 4vCPU, 16GiB arm64 $0.1344
  # t3a.xlarge - 4VCPU, 16GiB x86_64 AMD $0.1504
  # t3.xlarge - 4VCPU, 16GiB x86_64 Intel $0.1664
  instance_type_by_architecture = {
    arm64  = "t4g.xlarge"
    x86_64 = "t3a.xlarge"
  }

  instance_availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_instance" "dev" {

  ami           = data.aws_ami.dev.id
  instance_type = local.instance_type_by_architecture[var.architecture]

  availability_zone = local.instance_availability_zone

  key_name = aws_key_pair.dev.id

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
