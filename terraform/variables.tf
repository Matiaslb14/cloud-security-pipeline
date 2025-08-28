########################################
# Variables
########################################

# Región de AWS
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Dirección IP pública del administrador (con /32 al final)
variable "my_ip_cidr" {
  description = "Tu IP pública con máscara /32 (ejemplo: 181.226.xxx.xxx/32)"
  type        = string
}

# Nombre del par de llaves (key pair) que usarás para acceder por SSH
variable "key_pair_name" {
  description = "Nombre del key pair de AWS"
  type        = string
}

# Correo electrónico que recibirá alertas de CloudWatch
variable "alarm_email" {
  description = "Email para recibir alertas de CloudWatch"
  type        = string
}
