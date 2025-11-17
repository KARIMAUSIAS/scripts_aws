#creo la vpc y guardo el id
VPC_ID=$(aws ec2 create-vpc --cidr-block 192.168.0.0/24 \
--tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=VPC_KARIM}, {Key=entorno,Value=prueba}]' \
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

SUB2_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.0.16/28 \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=subred1-karim}]' \
    --query Subnet.SubnetId --output text)

echo $SUB2_ID

aws ec2 modify-subnet-attribute --subnet-id $SUB2_ID --map-public-ip-on-launch
