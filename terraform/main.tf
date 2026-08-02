terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Existing VPC
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = false

  tags = {
    Name = "devops-vpc"
  }
}

# Existing Public Subnet
resource "aws_subnet" "devops_subnet" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-subnet"
  }
}

# Existing Internet Gateway
resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "devops-igw"
  }
}

# Existing Route Table
resource "aws_route_table" "devops_route" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }

  tags = {
    Name = "devops-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "devops_association" {
  subnet_id      = aws_subnet.devops_subnet.id
  route_table_id = aws_route_table.devops_route.id
}

# Existing Security Group
resource "aws_security_group" "devops_sg" {
  name        = "devops-security-group"
  description = "Managed by Terraform"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Docker EC2 Server
resource "aws_instance" "docker_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = var.key_name

  subnet_id = aws_subnet.devops_subnet.id

  vpc_security_group_ids = [
    aws_security_group.devops_sg.id
  ]

  user_data = <<-EOF
              #!/bin/bash

              apt-get update -y

              apt-get install -y docker.io git

              systemctl enable docker
              systemctl start docker

              usermod -aG docker ubuntu

              cd /home/ubuntu

              git clone https://github.com/Vighnesh003/devops-final-project.git

              cd devops-final-project

              docker build -t devops-app:v1 .

              docker run -d \
                --name devops-app \
                -p 8080:80 \
                devops-app:v1
              EOF

  tags = {
    Name = "devops-docker-server"
  }
}