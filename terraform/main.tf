provider "aws" {
  region = "us-east-1"
}

# Security Group que permite SSH solo desde tu IP
resource "aws_security_group" "ssh_sg" {
  name        = "ssh-only"
  description = "Allow SSH only from my IP"

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia EC2
resource "aws_instance" "vm" {
  ami           = "ami-08c40ec9ead489470" # Ubuntu 22.04 LTS en us-east-1
  instance_type = "t2.micro"
  key_name      = var.key_pair_name
  security_groups = [aws_security_group.ssh_sg.name]

  tags = {
    Name = "CloudSecurityDemo"
  }
}
