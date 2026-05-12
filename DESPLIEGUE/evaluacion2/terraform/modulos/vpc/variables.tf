variable "environment" {
  description = "Entorno de despliegue"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto para los tags"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloque CIDR para la VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "El CIDR de la VPC no es válido."
  }
}

variable "public_subnets" {
  description = "Lista de CIDRs para las subnets públicas"
  type        = list(string)
}

variable "private_subnets" {
  description = "Lista de CIDRs para las subnets privadas"
  type        = list(string)
}

variable "availability_zones" {
  description = "Lista de AZs donde distribuir las subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Crear NAT Gateway para que subnets privadas accedan a internet"
  type        = bool
  default     = false
}
