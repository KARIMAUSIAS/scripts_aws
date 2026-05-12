variable "environment" {
  description = "Entorno de despliegue"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto para los tags"
  type        = string
}

# ---- Red (recibidos desde los outputs del módulo VPC) ----

variable "vpc_id" {
  description = "ID de la VPC donde se crearán los Security Groups"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subnet donde se lanzarán las instancias"
  type        = string
}

# ---- Configuración de la instancia ----

variable "ami_id" {
  description = "AMI a usar para las instancias EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia (t3.micro, t3.small, m5.large...)"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Número de instancias a crear"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "El número de instancias debe estar entre 1 y 10."
  }
}

variable "key_pair_name" {
  description = "Nombre del Key Pair para acceso SSH"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs que pueden conectarse por SSH (puerto 22)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # IMPORTANTE: restringir en producción
}

variable "root_volume_size" {
  description = "Tamaño del volumen raíz en GB"
  type        = number
  default     = 20
}
