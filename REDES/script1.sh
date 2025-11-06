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


#crear grupo de seguridad
SG_ID=$(aws ec2 create-security-group --group-name gs-karim --description "grupo de seguridad karim" \
    --vpc-id $VPC_ID \
    --output text)

#autorizar la entrada ssh
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

#creo un ec2
EC2_ID=$(aws ec2 run-instances \
    --image-id ami-0360c520857e3138f \
    --instance-type t3.micro \
    --key-name vockey \
    --subnet-id $SUB_ID \
    --associate-public-ip-address \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=myEC2}]' \
    --query Instances.InstanceId --output text)

sleep 15
echo $EC2_ID
