########################################
# Variables
########################################

# Región de AWS
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Tu IP pública en formato CIDR /32 (ej: 181.226.xxx.xxx/32)
variable "my_ip_cidr" {
  description = "Tu IP pública con máscara /32"
  type        = string
  validation {
    condition     = can(regex("\\/32$", var.my_ip_cidr))
    error_message = "my_ip_cidr debe terminar en /32, por ejemplo: 181.226.xxx.xxx/32"
  }
}

# Nombre del key pair (debe existir en la región)
variable "key_pair_name" {
  description = "Nombre del key pair de AWS"
  type        = string
}

# Email para alertas (opcional, por ahora no se usa)
variable "alarm_email" {
  description = "Email para recibir alertas de CloudWatch (opcional)"
  type        = string
  default     = ""
}

# Tipo de instancia EC2 (free-tier friendly)
variable "instance_type" {
  description = "Tipo de instancia EC2 a lanzar"
  type        = string
  default     = "t2.micro"   # 1 vCPU, evita problemas de cuota
}
