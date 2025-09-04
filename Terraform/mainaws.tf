terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "mum-vpc"
  }
}

resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.10.0/24"

  tags = {
    Name = "mum-pub-sub"
  }
}

resource "aws_subnet" "pvtsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.20.0/24"

  tags = {
    Name = "mum-pvt-sub"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "mum-igw"
  }
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = "mum-pub-rt"
  }
}

resource "aws_route_table_association" "pubassociation" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_eip" "myeip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "mynat" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "mum-nat"
  }
}

resource "aws_route_table" "pvtrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mynat.id
  }

  tags = {
    Name = "mum-pvt-rt"
  }
}

resource "aws_route_table_association" "pvtassociation" {
  subnet_id      = aws_subnet.pvtsub.id
  route_table_id = aws_route_table.pvtrt.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow All inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "mum-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ipv4-ssh" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = ["0.0.0.0/0"]
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "ipv4-http" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ipv4-https" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "pubec2" {
    ami                         =   "ami-08fe5144e4659a3b3"
    instance_type               =   "t2.micro"
    subnet_id                   =   aws_subnet.pubsub.id
    key_name                    =   "linux-mum"
    vpc_security_group_ids      =   [aws_security_group.allow_all.id]
    associate_public_ip_address =   true

    tags = {
    Name = "pub-ec2"
  }
}

resource "aws_instance" "pvtec2" {
    ami                         =   "ami-08fe5144e4659a3b3"
    instance_type               =   "t2.micro"
    subnet_id                   =   aws_subnet.pvtsub.id
    key_name                    =   "linux-mum"
    vpc_security_group_ids      =   [aws_security_group.allow_all.id]

    tags = {
    Name = "pvt-ec2"
  }
}