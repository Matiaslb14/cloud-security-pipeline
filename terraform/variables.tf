variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "my_ip" {
  description = "Tu IP pública con /32"
  type        = string
}

variable "key_pair_name" {
  description = "Nombre del key pair de AWS"
  type        = string
}

variable "alarm_email" {
  description = "Email para recibir alertas de CloudWatch"
  type        = string
}
