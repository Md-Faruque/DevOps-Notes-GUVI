terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# VPC
resource "aws_vpc" "devopschallenge_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "devopschallenge_vpc"
  }
}

# Subnets
resource "aws_subnet" "devopschallenge_public_subnet" {
  vpc_id     = aws_vpc.devopschallenge_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "devopschallenge_public_subnet"
  }
}

resource "aws_subnet" "devopschallenge_private_subnet" {
  vpc_id     = aws_vpc.devopschallenge_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "devopschallenge_private_subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "devopschallenge_igw" {
  vpc_id = aws_vpc.devopschallenge_vpc.id

  tags = {
    Name = "devopschallenge_igw"
  }
}

# Route Table (with default route to IGW)
resource "aws_route_table" "devopschallenge_routetable" {
  vpc_id = aws_vpc.devopschallenge_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devopschallenge_igw.id
  }

  tags = {
    Name = "devopschallenge_routetable"
  }
}

# Associate route table with subnets
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.devopschallenge_public_subnet.id
  route_table_id = aws_route_table.devopschallenge_routetable.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.devopschallenge_private_subnet.id
  route_table_id = aws_route_table.devopschallenge_routetable.id
}

# Security Group
resource "aws_security_group" "devopschallenge_sg" {
  name_prefix = "devopschallenge_sg"
  vpc_id      = aws_vpc.devopschallenge_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# EC2 Instance
resource "aws_instance" "devopschallenge_ec2instance" {
  ami           = "ami-0329ba0ced0243e2b"
  instance_type = "t3.micro"
  key_name      = "ubuntu-ohio"
  subnet_id     = aws_subnet.devopschallenge_public_subnet.id

  vpc_security_group_ids = [aws_security_group.devopschallenge_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<html><body><h1>Welcome to my website!</h1></body></html>" > /var/www/html/index.html
              sudo systemctl restart apache2
              EOF

  tags = {
    Name = "devopschallenge_ec2instance"
  }
}

# Allocate Elastic IP (no more `vpc = true`)
resource "aws_eip" "devopschallenge_eip" {
  tags = {
    Name = "devopschallenge_eip"
  }
}

# Associate EIP with the instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.devopschallenge_ec2instance.id
  allocation_id = aws_eip.devopschallenge_eip.id
}
