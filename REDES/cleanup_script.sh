#!/bin/bash

# ========================================
# SCRIPT DE LIMPIEZA DE INFRAESTRUCTURA AWS
# ========================================
# Este script elimina todos los recursos creados por script1.sh
# ORDEN DE ELIMINACIÓN (inverso a la creación):
# 1. Instancias EC2
# 2. Grupo de seguridad
# 3. NAT Gateway y IP elástica
# 4. Tablas de enrutamiento
# 5. Internet Gateway
# 6. Subredes
# 7. VPC

echo "=== INICIANDO LIMPIEZA DE INFRAESTRUCTURA ==="
echo "ADVERTENCIA: Este script eliminará TODOS los recursos con las etiquetas especificadas"
read -p "¿Está seguro de continuar? (y/N): " confirm

if [[ $confirm != [yY] ]]; then
    echo "Operación cancelada"
    exit 0
fi

# ========================================
# OBTENER IDs DE RECURSOS POR ETIQUETAS
# ========================================
echo "Obteniendo IDs de recursos..."

# VPC
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=VPC_KARIM" \
    --query 'Vpcs[0].VpcId' --output text)

if [ "$VPC_ID" = "None" ] || [ -z "$VPC_ID" ]; then
    echo "No se encontró VPC con nombre 'VPC_KARIM'"
    exit 1
fi

echo "VPC encontrada: $VPC_ID"

# Instancias EC2
EC2_PUB_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=ec2-publica-karim" "Name=instance-state-name,Values=running,stopped,stopping" \
    --query 'Reservations[0].Instances[0].InstanceId' --output text)

EC2_PRIV_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=ec2-privada-karim" "Name=instance-state-name,Values=running,stopped,stopping" \
    --query 'Reservations[0].Instances[0].InstanceId' --output text)

# Grupo de seguridad
SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=tag:Name,Values=sg-karim" "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[0].GroupId' --output text)

# NAT Gateway
NAT_GW_ID=$(aws ec2 describe-nat-gateways \
    --filter "Name=tag:Name,Values=NAT-Publica" "Name=vpc-id,Values=$VPC_ID" \
    --query 'NatGateways[0].NatGatewayId' --output text)

# IP Elástica
EIP_ALLOC_ID=$(aws ec2 describe-addresses \
    --filters "Name=tag:Name,Values=eip-nat-karim" \
    --query 'Addresses[0].AllocationId' --output text)

# Tablas de enrutamiento
TE_PUB_ID=$(aws ec2 describe-route-tables \
    --filters "Name=tag:Name,Values=rt-publica-karim" "Name=vpc-id,Values=$VPC_ID" \
    --query 'RouteTables[0].RouteTableId' --output text)

TE_PRIV_ID=$(aws ec2 describe-route-tables \
    --filters "Name=tag:Name,Values=rt-privada-karim" "Name=vpc-id,Values=$VPC_ID" \
    --query 'RouteTables[0].RouteTableId' --output text)

# Internet Gateway
IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=tag:Name,Values=igw-karim" \
    --query 'InternetGateways[0].InternetGatewayId' --output text)

# Subredes
SUB_PUB_ID=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=subred-publica-karim" "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[0].SubnetId' --output text)

SUB_PRIV_ID=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=subred-privada-karim" "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[0].SubnetId' --output text)

# ========================================
# 1. ELIMINAR INSTANCIAS EC2
# ========================================
echo "1. Eliminando instancias EC2..."

if [ "$EC2_PUB_ID" != "None" ] && [ -n "$EC2_PUB_ID" ]; then
    echo "Terminando instancia pública: $EC2_PUB_ID"
    aws ec2 terminate-instances --instance-ids $EC2_PUB_ID
fi

if [ "$EC2_PRIV_ID" != "None" ] && [ -n "$EC2_PRIV_ID" ]; then
    echo "Terminando instancia privada: $EC2_PRIV_ID"
    aws ec2 terminate-instances --instance-ids $EC2_PRIV_ID
fi

# Esperar a que las instancias se terminen
if [ "$EC2_PUB_ID" != "None" ] || [ "$EC2_PRIV_ID" != "None" ]; then
    echo "Esperando terminación de instancias..."
    sleep 30
fi

# ========================================
# 2. ELIMINAR GRUPO DE SEGURIDAD
# ========================================
echo "2. Eliminando grupo de seguridad..."

if [ "$SG_ID" != "None" ] && [ -n "$SG_ID" ]; then
    echo "Eliminando grupo de seguridad: $SG_ID"
    aws ec2 delete-security-group --group-id $SG_ID
fi

# ========================================
# 3. ELIMINAR NAT GATEWAY Y IP ELÁSTICA
# ========================================
echo "3. Eliminando NAT Gateway..."

if [ "$NAT_GW_ID" != "None" ] && [ -n "$NAT_GW_ID" ]; then
    echo "Eliminando NAT Gateway: $NAT_GW_ID"
    aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_ID
    
    echo "Esperando eliminación de NAT Gateway..."
    sleep 60
fi

if [ "$EIP_ALLOC_ID" != "None" ] && [ -n "$EIP_ALLOC_ID" ]; then
    echo "Liberando IP elástica: $EIP_ALLOC_ID"
    aws ec2 release-address --allocation-id $EIP_ALLOC_ID
fi

# ========================================
# 4. ELIMINAR TABLAS DE ENRUTAMIENTO
# ========================================
echo "4. Eliminando tablas de enrutamiento..."

if [ "$TE_PUB_ID" != "None" ] && [ -n "$TE_PUB_ID" ]; then
    echo "Eliminando tabla pública: $TE_PUB_ID"
    aws ec2 delete-route-table --route-table-id $TE_PUB_ID
fi

if [ "$TE_PRIV_ID" != "None" ] && [ -n "$TE_PRIV_ID" ]; then
    echo "Eliminando tabla privada: $TE_PRIV_ID"
    aws ec2 delete-route-table --route-table-id $TE_PRIV_ID
fi

# ========================================
# 5. ELIMINAR INTERNET GATEWAY
# ========================================
echo "5. Eliminando Internet Gateway..."

if [ "$IGW_ID" != "None" ] && [ -n "$IGW_ID" ]; then
    echo "Desasociando Internet Gateway: $IGW_ID"
    aws ec2 detach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
    
    echo "Eliminando Internet Gateway: $IGW_ID"
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
fi

# ========================================
# 6. ELIMINAR SUBREDES
# ========================================
echo "6. Eliminando subredes..."

if [ "$SUB_PUB_ID" != "None" ] && [ -n "$SUB_PUB_ID" ]; then
    echo "Eliminando subred pública: $SUB_PUB_ID"
    aws ec2 delete-subnet --subnet-id $SUB_PUB_ID
fi

if [ "$SUB_PRIV_ID" != "None" ] && [ -n "$SUB_PRIV_ID" ]; then
    echo "Eliminando subred privada: $SUB_PRIV_ID"
    aws ec2 delete-subnet --subnet-id $SUB_PRIV_ID
fi

# ========================================
# 7. ELIMINAR VPC
# ========================================
echo "7. Eliminando VPC..."

if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    echo "Eliminando VPC: $VPC_ID"
    aws ec2 delete-vpc --vpc-id $VPC_ID
fi

# ========================================
# RESUMEN DE LIMPIEZA
# ========================================
echo ""
echo "=== LIMPIEZA COMPLETADA ==="
echo "Recursos eliminados:"
echo "- Instancias EC2: $EC2_PUB_ID, $EC2_PRIV_ID"
echo "- Grupo de seguridad: $SG_ID"
echo "- NAT Gateway: $NAT_GW_ID"
echo "- IP elástica: $EIP_ALLOC_ID"
echo "- Tablas de enrutamiento: $TE_PUB_ID, $TE_PRIV_ID"
echo "- Internet Gateway: $IGW_ID"
echo "- Subredes: $SUB_PUB_ID, $SUB_PRIV_ID"
echo "- VPC: $VPC_ID"
echo ""
echo "Nota: Algunos recursos pueden tardar unos minutos en eliminarse completamente."