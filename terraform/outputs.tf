########################################
# Outputs
########################################

# IP pública de la instancia
output "instance_public_ip" {
  description = "IP pública de la instancia EC2"
  value       = aws_instance.vm.public_ip
}

# DNS público de la instancia
output "instance_public_dns" {
  description = "DNS público de la instancia EC2"
  value       = aws_instance.vm.public_dns
}

# Comando SSH listo para usar
output "ssh_command" {
  description = "Comando de conexión SSH"
  value       = "ssh -i ~/.ssh/mati-key.pem ubuntu@${aws_instance.vm.public_dns}"
}
