variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "El entorno debe ser dev, staging o prod."
  }
}

variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto, usado para los tags de los recursos"
  type        = string
  default     = "mi-proyecto"
}

# ---- Configuración de Red (pasadas al módulo VPC) ----

variable "vpc_cidr" {
  description = "Bloque CIDR para la VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Lista de CIDRs para subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Lista de CIDRs para subnets privadas"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "Zonas de disponibilidad de AWS"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ---- Configuración de EC2 (pasadas al módulo EC2) ----

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "ID de la Amazon Machine Image (AMI) para las instancias"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 en us-east-1
}

variable "instance_count" {
  description = "Número de instancias EC2 a crear"
  type        = number
  default     = 1
}

variable "key_pair_name" {
  description = "Nombre del Key Pair para acceso SSH"
  type        = string
  default     = "vockey"
}
