output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Lista de IDs de las subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Lista de IDs de las subnets privadas"
  value       = aws_subnet.private[*].id
}

output "vpc_cidr_block" {
  description = "Bloque CIDR de la VPC (para reglas de Security Group)"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.main.id
}
