#creo la vpc y guardo el id
VPC_ID=$(aws ec2 create-vpc --cidr-block 192.168.0.0/24 \
--tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=VPC_KARIM}]' \
--query Vpc.VpcId --output text)

#habilito dns en la vpc
aws ec2 modify-vpc-attribute \
    --vpc-id $VPC_ID \
    --enable-dns-hostnames "{\"Value\":true}"