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
# AMI Ubuntu 22.04 (elige x86_64 o arm64 según el tipo)
########################################
locals {
  # Si el tipo de instancia empieza con t4g. => ARM (Graviton)
  is_arm = can(regex("^t4g\\.", var.instance_type))
  arch   = local.is_arm ? "arm64" : "x86_64"
}

# Canonical (Ubuntu) owner ID: 099720109477
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    # Ejemplos de nombres de Canonical:
    # ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-x86_64-server-*
    # ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-${local.arch}-server-*"]
  }

  filter {
    name   = "architecture"
    values = [local.arch]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

########################################
# Security Group: SSH solo tu IP + HTTP público
########################################
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"
  description = "SSH from my IP, HTTP from all"
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }

  # SSH SOLO desde tu IP
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]      # ej: 181.226.x.x/32
  }

  # HTTP PÚBLICO (ajusta si quieres restringir)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida libre
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
  instance_type               = var.instance_type         # e.g. "t3.micro" (o "t4g.micro" si usas ARM)
  key_name                    = var.key_pair_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  # Instala y publica Nginx
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
