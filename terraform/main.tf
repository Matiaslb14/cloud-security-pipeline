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
# Security Group: solo SSH desde tu IP
########################################
resource "aws_security_group" "ssh_sg" {
  name_prefix = "ssh-only-"                      # evita nombre duplicado
  description = "Allow SSH only from my IP (22/tcp)"
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]               # ej: 181.226.x.x/32
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "ssh-only" }
}

########################################
# EC2 (Ubuntu 22.04 LTS, us-east-1)
########################################
resource "aws_instance" "vm" {
  ami                         = "ami-08c40ec9ead489470" # Ubuntu 22.04 LTS (us-east-1, x86_64)
  instance_type               = var.instance_type       # <-- ahora parametrizado
  key_name                    = var.key_pair_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ssh_sg.id]

  tags = { Name = "CloudSecurityDemo" }
}
