data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # t4g.xlarge - 4vCPU, 16GiB arm64 $0.1344
  # t3a.xlarge - 4VCPU, 16GiB x86_64 AMD $0.1504
  # t3.xlarge - 4VCPU, 16GiB x86_64 Intel $0.1664
  instance_type_by_architecture = {
    arm64  = "t4g.xlarge"
    x86_64 = "t3a.xlarge"
  }

  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_key_pair" "dev" {
  key_name_prefix = "dev"
  public_key      = var.ssh_public_key
}

resource "aws_vpc" "dev" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "172.16.0.0/24"
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id
}

resource "aws_route" "to_internet" {
  route_table_id = aws_route_table.public.id
  gateway_id     = aws_internet_gateway.dev.id

  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
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
  subnet_id       = aws_subnet.public.id
  security_groups = [aws_security_group.dev.id]
}

/*
data "aws_ami" "dev" {
  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}
*/

resource "aws_ebs_volume" "dev" {
  availability_zone = local.availability_zone
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

resource "aws_instance" "dev" {

  ami           = var.ami.id
  instance_type = local.instance_type_by_architecture[var.ami.architecture]

  key_name = aws_key_pair.dev.id

  ebs_optimized = true

  network_interface {
    network_interface_id = aws_network_interface.dev.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  depends_on = [aws_internet_gateway.dev]
}

resource "aws_volume_attachment" "dev" {
  # device_name is required by terraform, but overwritten by AWS.
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.dev.id
  instance_id = aws_instance.dev.id
}
