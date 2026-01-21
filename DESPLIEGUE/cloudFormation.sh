aws cloudformation create-stack \
  --stack-name webapp-rds-stack \
  --template-body file:///home/karrezmou/Escritorio/plantillas-yml/rds.yml \
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

