# Variables
AMI_ID="ami-0ecb62995f68bb549"
INSTANCE_TYPE="t3.micro"
KEY_NAME="vockey"
SEC_GROUP_NAME="webmin-sg"
SEC_GROUP_DESC="Permite acceso a Webmin y SSH"
USER_DATA_FILE="installwebmin.txt"

# Obtener la VPC por defecto
VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query "Vpcs[0].VpcId" --output text)

# Obtener la subred por defecto
SUBNET_ID=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --query "Subnets[0].SubnetId" --output text)

# Crear grupo de seguridad
SG_ID=$(aws ec2 create-security-group \
  --group-name $SEC_GROUP_NAME --description "$SEC_GROUP_DESC" --vpc-id $VPC_ID \
  --query "GroupId" --output text)

SG_ID_ARN=$(echo $SG_ID | cut -d' ' -f2)
SG_ID=$(echo $SG_ID | cut -d' ' -f1)

# Permitir acceso SSH (22) y Webmin (10000) desde cualquier IP
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 10000 --cidr 0.0.0.0/0

# Lanzar la instancia usando el script de user-data
aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --user-data file://$USER_DATA_FILE

echo "Instancia Webmin lanzada en la subred por defecto."

