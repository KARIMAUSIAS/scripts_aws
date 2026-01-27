# Para rds.yml

aws cloudformation create-stack \
  --stack-name webapp-rds-stack \
  --template-body file:///home/karrezmou/Escritorio/plantillas-yml/rdsoriginal.yml \
  --parameters \
    ParameterKey=AvailabilityZone,ParameterValue=us-east-1a \
    ParameterKey=EnvironmentType,ParameterValue=dev \
    ParameterKey=KeyPairName,ParameterValue=vockey \
    ParameterKey=DBInstanceIdentifier,ParameterValue=webapp-db \
    ParameterKey=DBPassword,ParameterValue='TuPassLarga123' \
    ParameterKey=DBName,ParameterValue=webapp 


# Comando para validar la plantilla
aws cloudformation validate-template --template-body file:///home/karrezmou/Escritorio/plantillas-yml/rds.yml


# CAMBIAR DBInstanceIdentifier CADA VEZ QUE SE HACE UN UPDATE
aws cloudformation update-stack \
  --stack-name webapp-rds-stack \
  --template-body file:///home/karrezmou/Escritorio/plantillas-yml/rds.yml \
  --parameters \
    ParameterKey=AvailabilityZone,ParameterValue=us-east-1a \
    ParameterKey=EnvironmentType,ParameterValue=dev \
    ParameterKey=KeyPairName,ParameterValue=vockey \
    ParameterKey=DBInstanceIdentifier,ParameterValue=webapp2-db \
    ParameterKey=DBPassword,ParameterValue='TuPassLarga123' \
    ParameterKey=DBName,ParameterValue=webapp


aws cloudformation delete-stack \
  --stack-name webapp-rds-stack 


aws cloudformation create-stack \
  --stack-name vpc-ec2-karim \
  --template-body file:///home/karrezmou/Escritorio/plantillas-yml/aws4-02-1.yml \
  --parameters \
  ParameterKey=InstanceType,ParameterValue=t3.micro \
  ParameterKey=CrearInstancia,ParameterValue=true

aws cloudformation create-stack \
  --stack-name vpc-multiregion-karim \
  --template-body file:///home/karrezmou/Escritorio/plantillas-yml/aws4-02-2.yml \
  --region us-east-1 \
  --parameters \
  ParameterKey=AttachIGW,ParameterValue=true 


aws cloudformation create-stack \
  --stack-name alb-asg \
  --template-body file:///home/karrezmou/Escritorio/plantillas-yml/aws4-02-3.yml \
  --parameters \
  ParameterKey=InstanceType,ParameterValue=t3.micro \
  ParameterKey=ALBPublico,ParameterValue=true \
  ParameterKey=NombreBase,ParameterValue=vivalalandingkarim


aws cloudformation create-stack \
  --stack-name vpc-peering \
  --template-body file:///home/karrezmou/Escritorio/plantillas-yml/aws4-03-1.yml \
  --parameters \
    ParameterKey=Ambiente,ParameterValue=Dev \
    ParameterKey=VpcDestinoPeering,ParameterValue=vpc-0141d073ec666866a \
    ParameterKey=PublicSubnet1Cidr,ParameterValue=20.0.1.0/24 \
    ParameterKey=PublicSubnet2Cidr,ParameterValue=20.0.2.0/24 \
    ParameterKey=PrivateSubnet1Cidr,ParameterValue=20.0.10.0/24 \
    ParameterKey=PrivateSubnet2Cidr,ParameterValue=20.0.11.0/24

aws cloudformation deploy \
  --template-file /home/karrezmou/Escritorio/plantillas-yml/aws4-03-2.yml \
  --stack-name stack-vpc-rds \
  --parameter-overrides \
    Ambiente=Dev \
    VpcId=vpc-0317742a40d2b3841 \
    PrivateSubnet1Id=subnet-04d2ab9ecb5222562 \
    PrivateSubnet2Id=subnet-0bfce609d817c1cb5 \
    DBEngineVersion=8.0.43 \
    DBUsername=admin \
    DBPassword=adminadmin

aws cloudformation create-stack \
  --stack-name stack-s3 \
  --template-body file:///home/karrezmou/Escritorio/plantillas-yml/aws4-03-3.yml \
  --parameters \
    ParameterKey=AccessLevel,ParameterValue=Privado \
    ParameterKey=BucketName,ParameterValue=prueba-s3-stack-karim \
    ParameterKey=StorageType,ParameterValue=IntelligentTiering 