########################################
# Provider
########################################
provider "aws" {
  region = var.aws_region
}

########################################
# VPC/Subred por defecto
########################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

########################################
# AMI Ubuntu 22.04 (resiliente a nombre)
########################################
locals {
  # ARM si el tipo empieza con t4g., si no x86_64
  is_arm = can(regex("^t4g\\.", var.instance_type))
  arch   = local.is_arm ? "arm64" : "x86_64"
}

# Canonical: 099720109477
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    # evita meter la arquitectura en el nombre; la filtramos abajo
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*-server-*"]
  }

  filter {
    name   = "architecture"
    values = [local.arch]        # "x86_64" o "arm64"
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

########################################
# Security Group: SSH solo tu IP + HTTP público
########################################
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"
  description = "SSH from my IP, HTTP from all"
  vpc_id      = data.aws_vpc.default.id

  lifecycle { create_before_destroy = true }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web-sg" }
}

########################################
# EC2 (Ubuntu 22.04 LTS) + Nginx
########################################
resource "aws_instance" "vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    set -xe
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
    cat > /var/www/html/index.html <<'HTML'
    <!doctype html>
    <html>
      <head><meta charset="utf-8"><title>Cloud Security Demo</title></head>
      <body style="font-family: system-ui; margin: 40px;">
        <h1>¡Despliegue OK! 🚀</h1>
        <p>EC2 + Terraform + GitHub Actions + Nginx.</p>
      </body>
    </html>
    HTML
    systemctl enable nginx
    systemctl restart nginx
  EOF

  tags = { Name = "CloudSecurityDemo" }
}
