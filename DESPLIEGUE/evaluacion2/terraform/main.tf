provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "mi_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "MiVPC"
  }
}

# Crear una subred dentro de la VPC
resource "aws_subnet" "mi_subnet" {
  vpc_id            = aws_vpc.mi_vpc.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "MiSubnet"
  }
}

#Crear el grupo de seguridad
resource "aws_security_group" "mi_sg" {
  name        = "mi_sg"
  description = "Grupo de seguridad para mi instancia EC2"
  vpc_id      = aws_vpc.mi_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_instance" "ejemplo" {
  ami           = "ami-091138d0f0d41ff90"
  instance_type = "t3.micro"
  key_name      = "vockey"
  subnet_id     = aws_subnet.mi_subnet.id
  vpc_security_group_ids = [aws_security_group.mi_sg]

  tags = {
    Name = "EC2Instance"
  }
}

