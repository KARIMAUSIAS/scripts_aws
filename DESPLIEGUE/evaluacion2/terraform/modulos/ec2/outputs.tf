output "instance_ids" {
  description = "Lista de IDs de las instancias EC2 creadas"
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "Lista de IPs públicas de las instancias"
  value       = aws_instance.web[*].public_ip
}

output "private_ips" {
  description = "Lista de IPs privadas de las instancias"
  value       = aws_instance.web[*].private_ip
}

output "security_group_id" {
  description = "ID del Security Group creado"
  value       = aws_security_group.ec2_sg.id
}

output "ssh_connection_commands" {
  description = "Comandos para conectarse por SSH a cada instancia"
  value = [
    for ip in aws_instance.web[*].public_ip :
    "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${ip}"
  ]
}
