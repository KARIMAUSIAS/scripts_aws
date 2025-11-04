# Variables principales              
SN_ID="subnet-0d2ab3f307f7186f1"
I1_ID="i-046b235da5860a4d0"
I2_ID="i-0d2edfb178f104ea4"
VPC_ID="vpc-0d8c42ab0301faae7"       

# crear grupo de seguridad
SG_ID=$(aws ec2 create-security-group \
  --group-name "sgbalanceador" \
  --description "grupo de seguridad para elb" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text)

echo $SG_ID

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

# creacion del grupo de destino
TG_ARN=$(aws elbv2 create-target-group \
    --name tg-act2 \
    --protocol TCP \
    --port 80 \
    --target-type instance \
    --vpc-id $VPC_ID \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

echo $TG_ARN

# registrar las instancias
aws elbv2 register-targets \
    --target-group-arn $TG_ARN \
    --targets Id=$I1_ID Id=$I2_ID

# crear el balanceador de carga 
LB_ARN=$(aws elbv2 create-load-balancer \
  --name "elb-karim" \
  --subnets $SN_ID \
  --security-groups $SG_ID \
  --type network \
  --scheme internet-facing \
  --ip-address-type ipv4 \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text)

echo $LB_ARN

# crear el agente de escucha
LISTENER_ARN=$(aws elbv2 create-listener \
  --load-balancer-arn $LB_ARN \
  --protocol TCP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=$TG_ARN \
  --query 'Listeners[0].ListenerArn' --output text)

# obtener el DNS del balanceador
LB_DNS=$(aws elbv2 describe-load-balancers \
  --load-balancer-arns $LB_ARN \
  --query 'LoadBalancers[0].DNSName' --output text)

echo $LB_DNS


