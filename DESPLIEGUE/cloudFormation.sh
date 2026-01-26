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
  --parameters \
  ParameterKey=AttachIGW,ParameterValue=true
