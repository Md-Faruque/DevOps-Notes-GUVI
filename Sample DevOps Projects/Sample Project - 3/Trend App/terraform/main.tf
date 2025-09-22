provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "trend-vpc" }
}

# Security Group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 for Jenkins
resource "aws_instance" "jenkins" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "<your-key>"
  security_groups = [aws_security_group.sg.name]
  tags = { Name = "jenkins-server" }
}