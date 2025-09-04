variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 Key Pair name (set this to SSH in). Leave empty for none."
  type        = string
  default     = "ubuntu-ohio" # Make sure to change the Key name accordingly
}

variable "allow_ssh_cidr" {
  description = "CIDR allowed to SSH (set to your IP in production)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allow_http" {
  description = "Whether to open port 80 (HTTP)"
  type        = bool
  default     = true
}

variable "instance_name" {
  description = "Name tag for instance"
  type        = string
  default     = "tf-ec2-instance"
}

variable "tags" {
  description = "Extra resource tags"
  type        = map(string)
  default     = {
    Owner = "terraform"
  }
}