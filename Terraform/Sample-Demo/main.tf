# 1. Get latest Amazon Linux 2 AMI
data "aws_ami" "amazonlinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 2. Security group
resource "aws_security_group" "instance_sg" {
  name        = "${var.instance_name}-sg"
  description = "Allow SSH + optional HTTP"
  tags        = merge(var.tags, { Name = "${var.instance_name}-sg" })

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_ssh_cidr]
  }

  dynamic "ingress" {
    for_each = var.allow_http ? [1] : []
    content {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. EC2 instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazonlinux2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  key_name = var.key_name != "" ? var.key_name : null

  tags = merge(var.tags, { Name = var.instance_name })

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
              echo "<h1>Deployed by Terraform</h1><p>Instance: $INSTANCE_ID</p>" > /var/www/html/index.html
              EOF
}