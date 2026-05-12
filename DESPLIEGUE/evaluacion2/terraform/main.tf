terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # backend "s3" {
  #   bucket = "mi-terraform-state"
  #   key    = "03_ejemplo/terraform.tfstate"
  #   region = "eu-west-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ============================================================
#  MÓDULO VPC - Se crea primero (EC2 depende de sus outputs)
# ============================================================

module "vpc" {
  source = "./modulos/vpc"

  environment        = var.environment
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
}

# ============================================================
#  MÓDULO EC2 - Usa los outputs de VPC para ubicar instancias
# ============================================================

module "ec2" {
  source = "./modulos/ec2"

  environment    = var.environment
  project_name   = var.project_name
  instance_type  = var.instance_type
  ami_id         = var.ami_id
  instance_count = var.instance_count
  key_pair_name  = var.key_pair_name

  # Valores provenientes del módulo VPC (encadenamiento de módulos)
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]

  depends_on = [module.vpc]
}

# ============================================================
#  OUTPUTS DEL PROYECTO RAÍZ
# ============================================================

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.vpc.vpc_id
}

output "instancias_publicas" {
  description = "IPs públicas de las instancias EC2"
  value       = module.ec2.public_ips
}
