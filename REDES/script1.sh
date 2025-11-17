#creo la vpc y guardo el id
VPC_ID=$(aws ec2 create-vpc --cidr-block 192.168.0.0/24 \
--tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=VPC_KARIM}]' \
--query Vpc.VpcId --output text)

echo $VPC_ID

#habilito dns en la vpc
aws ec2 modify-vpc-attribute \
    --vpc-id $VPC_ID \
    --enable-dns-hostnames "{\"Value\":true}"

SUB_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.0.0/28 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subred1-karim}]' \
    --query Subnet.SubnetId --output text)

echo $SUB_ID

aws ec2 modify-subnet-attribute --subnet-id $SUB_ID --map-public-ip-on-launch

#creacion internet getway
IGW_ID=$(aws ec2 create-internet-gateway \
 --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=igw-karim}]' \
 --query InternetGateway.InternetGatewayId --output text)

#asociar internet getway a la vpc
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

#creacion de la tabla de enrutamiento
TE_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --query RouteTable.RouteTableId \
    --output text)

#agregar la ruta para la salida a internet
aws ec2 create-route \
    --route-table-id $TE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

#asociar la tabla de enrutamiento a una subred
aws ec2 associate-route-table \
    --subnet-id $SUB_ID \
    --route-table-id $TE_ID \
    --query AssociationId \
    --output text

# Creación del grupo de seguridad
SG_ID=$(aws ec2 create-security-group --group-name My-SG \
    --description "grupo seguridad puerto 22" \
    --vpc-id $VPC_ID \
    --output text)

SG_ID_ARN=$(echo $SG_ID | cut -d' ' -f2)
SG_ID=$(echo $SG_ID | cut -d' ' -f1)

## Autorización de abrir el puerto 22 para el grupo de seguridad
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 > /dev/null

aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 > /dev/null

aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 > /dev/null

echo $SG_ID

### Habilitar la asginación de IPv4 Pública en la subred
aws ec2 modify-subnet-attribute --subnet-id $SUB_ID --map-public-ip-on-launch 

EC2_ID=$(aws ec2 run-instances \
    --image-id ami-0ecb62995f68bb549 \
    --instance-type t3.micro \
    --subnet-id $SUB_ID \
    --security-group-ids $SG_ID \
    --associate-public-ip-address \
    --count 1 \
    --key-name vockey \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ec2-karim}]' \
    --query Instances.InstanceId --output text)

echo $EC2_ID

# En caso de NO indicar el grupo de seguridad se haría de la siguiente manera:
# aws ec2 modify-instance-attribute --instance-id $EC2_ID --groups $SG_ID

#Para desasociar de una tabla de enrutamiento
#AS_ID=$(aws ec2 describe-route-tables --filters Name=association.subnet-id,Values=$SUB_ID --query "RouteTables[0].Associations[?SubnetId!=null].RouteTableAssociationId" --output text)
#aws ec2 disassociate-route-table --association-id $AS_ID