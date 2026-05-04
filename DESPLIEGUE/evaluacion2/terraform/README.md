# Terraform AWS EC2 Example

Este proyecto contiene una configuración de Terraform para crear una infraestructura básica en AWS.

## Recursos creados

- `aws_vpc.mi_vpc`: VPC con CIDR `192.168.0.0/16`
- `aws_subnet.mi_subnet`: Subred en la VPC con CIDR `192.168.1.0/24` en la zona `us-east-1a`
- `aws_security_group.mi_sg`: Grupo de seguridad que permite tráfico entrante HTTP (puerto 80) desde cualquier origen y permite todo el tráfico saliente
- `aws_instance.ejemplo`: Instancia EC2 de tipo `t3.micro` usando la AMI `ami-091138d0f0d41ff90`, asociada a la subred y al grupo de seguridad

## Requisitos

- Terraform instalado
- Credenciales de AWS configuradas en el equipo
- Clave SSH llamada `vockey` ya creada en AWS (o modificar `key_name` con el nombre de tu clave)

## Uso

Desde el directorio `DESPLIEGUE/evaluacion2/terraform` ejecutar:

```bash
terraform init
terraform plan
terraform apply
```

Para destruir los recursos:

```bash
terraform destroy
```

## Notas

- Asegúrate de que la AMI `ami-091138d0f0d41ff90` esté disponible en la región `us-east-1`.
- Si no tienes la clave SSH `vockey`, cambia `key_name` en `main.tf` a una clave existente en tu cuenta de AWS.
