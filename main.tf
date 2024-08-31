terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Include the providers
provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "sd3971-devops-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}


resource "aws_subnet" "subnet" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet[0].id
  route_table_id = aws_route_table.route_table.id
}


# EC2 Instance
resource "aws_instance" "default" {
  ami                         = "ami-0d07675d294f17973"
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_instance_connect.id]
  subnet_id                   = aws_subnet.subnet[0].id

  tags = {
    Name = "SD3971Instance"
  }
}


resource "aws_security_group" "allow_ssh_instance_connect" {
  name        = "allow_ssh_instance_connect"
  description = "Allow SSH inbound traffic from EC2 Instance Connect IP ranges"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.0.5.32/29"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ECR Repository
resource "aws_ecr_repository" "frontend_repo" {
  name                 = "frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}


# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  subnet_ids = aws_subnet.subnet[*].id
  vpc_id     = aws_vpc.main.id

  eks_managed_node_groups = {
    example = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type = var.ec2_instance_type
    }
  }

  tags = {
    Environment = "dev"
    Name        = var.cluster_name
  }
}

