#!/bin/bash

# ========================================
# SCRIPT DE CREACIÓN DE INFRAESTRUCTURA AWS
# ========================================
# Este script crea una infraestructura completa de red en AWS:
# - VPC con subredes pública y privada
# - Internet Gateway y NAT Gateway
# - Tablas de enrutamiento
# - Grupo de seguridad
# - Instancias EC2

echo "=== INICIANDO CREACIÓN DE INFRAESTRUCTURA ==="

# ========================================
# 1. CREACIÓN DE VPC
# ========================================
echo "1. Creando VPC..."
VPC_ID=$(aws ec2 create-vpc --cidr-block 192.168.0.0/16 \
--tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=VPC_KARIM}]' \
--query Vpc.VpcId --output text)

echo "VPC creada con ID: $VPC_ID"

# Habilitar DNS hostnames en la VPC
echo "Habilitando DNS hostnames..."
aws ec2 modify-vpc-attribute \
    --vpc-id $VPC_ID \
    --enable-dns-hostnames "{\"Value\":true}"

# ========================================
# 2. CREACIÓN DE SUBREDES
# ========================================
echo "2. Creando subredes..."

# Subred pública
SUB_PUB_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.12.0/24 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subred-publica-karim}]' \
    --query Subnet.SubnetId --output text)

# Subred privada
SUB_PRIV_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.138.0/24 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subred-privada-karim}]' \
    --query Subnet.SubnetId --output text)

echo "Subred pública: $SUB_PUB_ID"
echo "Subred privada: $SUB_PRIV_ID"

# Habilitar asignación automática de IP pública en subred pública
echo "Habilitando IP pública automática en subred pública..."
aws ec2 modify-subnet-attribute --subnet-id $SUB_PUB_ID --map-public-ip-on-launch

# ========================================
# 3. CREACIÓN DE INTERNET GATEWAY
# ========================================
echo "3. Creando Internet Gateway..."
IGW_PUB_ID=$(aws ec2 create-internet-gateway \
 --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-karim}]' \
 --query InternetGateway.InternetGatewayId --output text)

echo "Internet Gateway creado: $IGW_PUB_ID"

# Asociar Internet Gateway a la VPC
echo "Asociando Internet Gateway a la VPC..."
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_PUB_ID

# ========================================
# 4. CREACIÓN DE TABLAS DE ENRUTAMIENTO
# ========================================
echo "4. Creando tablas de enrutamiento..."

# Tabla de enrutamiento para subred pública
TE_PUB_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=rt-publica-karim}]' \
    --query RouteTable.RouteTableId \
    --output text)

# Tabla de enrutamiento para subred privada
TE_PRIV_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=rt-privada-karim}]' \
    --query RouteTable.RouteTableId \
    --output text)

echo "Tabla pública: $TE_PUB_ID"
echo "Tabla privada: $TE_PRIV_ID"

# Asociar subredes a sus respectivas tablas de enrutamiento
echo "Asociando subredes a tablas de enrutamiento..."
aws ec2 associate-route-table \
    --subnet-id $SUB_PUB_ID \
    --route-table-id $TE_PUB_ID \
    --query AssociationId \
    --output text

aws ec2 associate-route-table \
    --subnet-id $SUB_PRIV_ID \
    --route-table-id $TE_PRIV_ID

# Agregar ruta a Internet en tabla pública
echo "Creando ruta a Internet Gateway..."
aws ec2 create-route \
    --route-table-id $TE_PUB_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_PUB_ID

# ========================================
# 5. CREACIÓN DE NAT GATEWAY
# ========================================
echo "5. Creando NAT Gateway..."

# Asignar IP elástica para el NAT Gateway
echo "Asignando IP elástica..."
EIP_ALLOC_ID=$(aws ec2 allocate-address \
--domain vpc \
--tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=eip-nat-karim}]' \
--query 'AllocationId' \
--output text)

echo "IP elástica asignada: $EIP_ALLOC_ID"

# Crear NAT Gateway
echo "Creando NAT Gateway..."
NAT_GW_ID=$(aws ec2 create-nat-gateway \
--subnet-id $SUB_PUB_ID \
--allocation-id $EIP_ALLOC_ID \
--tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=NAT-Publica}]' \
--query 'NatGateway.NatGatewayId' \
--output text)

echo "NAT Gateway creado: $NAT_GW_ID"
echo "Esperando que NAT Gateway esté disponible..."
sleep 60

# Crear ruta hacia NAT Gateway en tabla privada
echo "Creando ruta a NAT Gateway..."
aws ec2 create-route \
--route-table-id $TE_PRIV_ID \
--destination-cidr-block 0.0.0.0/0 \
--nat-gateway-id $NAT_GW_ID

# ========================================
# 6. CREACIÓN DE GRUPO DE SEGURIDAD
# ========================================
echo "6. Creando grupo de seguridad..."

# Crear grupo de seguridad
SG_ID=$(aws ec2 create-security-group \
    --group-name My-SG-Karim \
    --description "Grupo de seguridad para instancias" \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=sg-karim}]' \
    --query GroupId \
    --output text)

echo "Grupo de seguridad creado: $SG_ID"

# Autorizar tráfico entrante
echo "Configurando reglas de seguridad..."

# Puerto 22 (SSH)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Puerto 80 (HTTP)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Puerto 443 (HTTPS)
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

echo "Reglas de seguridad configuradas"

# ========================================
# 7. CREACIÓN DE INSTANCIAS EC2
# ========================================
echo "7. Creando instancias EC2..."

# Instancia en subred pública
echo "Creando instancia pública..."
EC2_PUB_ID=$(aws ec2 run-instances \
    --image-id ami-0ecb62995f68bb549 \
    --instance-type t3.micro \
    --subnet-id $SUB_PUB_ID \
    --security-group-ids $SG_ID \
    --associate-public-ip-address \
    --count 1 \
    --key-name vockey \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ec2-publica-karim}]' \
    --query 'Instances[0].InstanceId' --output text)

# Instancia en subred privada (sin IP pública)
echo "Creando instancia privada..."
EC2_PRIV_ID=$(aws ec2 run-instances \
    --image-id ami-0ecb62995f68bb549 \
    --instance-type t3.micro \
    --subnet-id $SUB_PRIV_ID \
    --security-group-ids $SG_ID \
    --no-associate-public-ip-address \
    --count 1 \
    --key-name vockey \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ec2-privada-karim}]' \
    --query 'Instances[0].InstanceId' --output text)

echo "Instancia pública: $EC2_PUB_ID"
echo "Instancia privada: $EC2_PRIV_ID"

# ========================================
# RESUMEN DE RECURSOS CREADOS
# ========================================
echo ""
echo "=== INFRAESTRUCTURA CREADA EXITOSAMENTE ==="
echo "VPC ID: $VPC_ID"
echo "Subred Pública: $SUB_PUB_ID"
echo "Subred Privada: $SUB_PRIV_ID"
echo "Internet Gateway: $IGW_PUB_ID"
echo "NAT Gateway: $NAT_GW_ID"
echo "Grupo de Seguridad: $SG_ID"
echo "Instancia Pública: $EC2_PUB_ID"
echo "Instancia Privada: $EC2_PRIV_ID"
echo ""
echo "Nota: Las instancias pueden tardar unos minutos en estar completamente disponibles."

# ========================================
# COMANDOS ÚTILES PARA LIMPIEZA (COMENTADOS)
# ========================================
# Para desasociar de una tabla de enrutamiento:
# AS_ID=$(aws ec2 describe-route-tables --filters Name=association.subnet-id,Values=$SUB_PUB_ID --query "RouteTables[0].Associations[?SubnetId!=null].RouteTableAssociationId" --output text)
# aws ec2 disassociate-route-table --association-id $AS_ID
#
# Para eliminar recursos (ejecutar en orden inverso):
# aws ec2 terminate-instances --instance-ids $EC2_PUB_ID $EC2_PRIV_ID
# aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_ID
# aws ec2 release-address --allocation-id $EIP_ALLOC_ID
# aws ec2 delete-security-group --group-id $SG_ID
# aws ec2 delete-route-table --route-table-id $TE_PUB_ID
# aws ec2 delete-route-table --route-table-id $TE_PRIV_ID
# aws ec2 detach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_PUB_ID
# aws ec2 delete-internet-gateway --internet-gateway-id $IGW_PUB_ID
# aws ec2 delete-subnet --subnet-id $SUB_PUB_ID
# aws ec2 delete-subnet --subnet-id $SUB_PRIV_ID
# aws ec2 delete-vpc --vpc-id $VPC_ID