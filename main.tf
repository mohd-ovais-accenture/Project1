terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "project1_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "project1-vpc"
  }
}

resource "aws_subnet" "project1_public_subnet" {
  vpc_id                  = aws_vpc.project1_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "project1-public-subnet"
  }
}

resource "aws_internet_gateway" "project1_igw" {
  vpc_id = aws_vpc.project1_vpc.id

  tags = {
    Name = "project1-igw"
  }
}

resource "aws_route_table" "project1_public_rt" {
  vpc_id = aws_vpc.project1_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project1_igw.id
  }

  tags = {
    Name = "project1-public-rt"
  }
}

resource "aws_route_table_association" "project1_public_rta" {
  subnet_id      = aws_subnet.project1_public_subnet.id
  route_table_id = aws_route_table.project1_public_rt.id
}

resource "aws_security_group" "project1_web_sg" {
  name        = "project1-web-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.project1_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project1-web-sg"
  }
}

resource "aws_instance" "project1_web_server" {
  ami                    = data.aws_ami.ubuntu_2404.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.project1_public_subnet.id
  vpc_security_group_ids = [aws_security_group.project1_web_sg.id]
  user_data              = file("${path.module}/userdata.sh")

  tags = {
    Name = "project1-ec2-webserver"
  }
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.project1_web_server.public_ip
}

output "webpage_url" {
  description = "URL to open the hosted webpage"
  value       = "http://${aws_instance.project1_web_server.public_ip}"
}
