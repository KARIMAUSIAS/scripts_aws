#Conseguir ID de la ec2
EC2_ID=$(aws ec2 describe-instances    \
    --query Reservations[0].Instances[0].[InstanceId,State.Name]    \
    --output text)

EC2_STATUS=$(echo $EC2_ID | cut -d' ' -f2)
EC2_ID=$(echo $EC2_ID | cut -d' ' -f1)

if [ "$EC2_STATUS" = "running" ]
then
#Parando instancia
aws ec2 stop-instances \
    --instance-ids $EC2_ID

#Esperando a que la instancia se pare
aws ec2 wait instance-stopped \
    --instance-ids $EC2_ID

echo ""
echo "Instancia parada"
echo ""

else
echo "Instancia ya está parada"
fi

#Cambiando el tipo de instancia
aws ec2 modify-instance-attribute \
    --instance-id $EC2_ID \
    --instance-type "{\"Value\": \"t3.micro\"}"

echo ""
echo "Tipo de instancia cambiada"
echo ""
#Volver a iniciar la instancia
aws ec2 start-instances --instance-ids $EC2_ID

#Esperar a que la instancia se inicie de nuevo
aws ec2 wait instance-running \
    --instance-ids $EC2_ID

echo ""
echo "Instancia iniciada de nuevo"
echo ""
