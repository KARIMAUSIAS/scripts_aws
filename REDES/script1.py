import boto3

def crear_vpc(ec2):
    """Crea una VPC con DNS habilitado y la etiqueta correspondiente."""
    print("1. Creando VPC...")
    
    # Crear la VPC
    vpc = ec2.create_vpc(CidrBlock='192.168.0.0/16')
    vpc_id = vpc['Vpc']['VpcId']
    print(f"VPC creada con ID: {vpc_id}")

    # Habilitar DNS support
    ec2.modify_vpc_attribute(
        VpcId=vpc_id,
        EnableDnsSupport={'Value': True}
    )

    # Habilitar DNS hostnames
    ec2.modify_vpc_attribute(
        VpcId=vpc_id,
        EnableDnsHostnames={'Value': True}
    )

    # Etiquetar la VPC
    ec2.create_tags(
        Resources=[vpc_id],
        Tags=[{'Key': 'Name', 'Value': 'VPC_KARIM'}]
    )

    print("DNS habilitado y etiqueta 'VPC_KARIM' asignada.")
    return vpc_id


def crear_subredes(ec2, vpc_id):
    """Crea subredes pública y privada, y habilita IP pública automática."""
    print("2. Creando subredes...")
    
    # Crear subred pública
    subnet_pub = ec2.create_subnet(
        VpcId=vpc_id,
        CidrBlock='192.168.12.0/24'
    )
    subnet_pub_id = subnet_pub['Subnet']['SubnetId']
    print(f"Subred pública creada: {subnet_pub_id}")
    
    # Etiquetar subred pública
    ec2.create_tags(
        Resources=[subnet_pub_id],
        Tags=[{'Key': 'Name', 'Value': 'subred-publica-karim'}]
    )
    
    # Crear subred privada
    subnet_priv = ec2.create_subnet(
        VpcId=vpc_id,
        CidrBlock='192.168.138.0/24'
    )
    subnet_priv_id = subnet_priv['Subnet']['SubnetId']
    print(f"Subred privada creada: {subnet_priv_id}")
    
    # Etiquetar subred privada
    ec2.create_tags(
        Resources=[subnet_priv_id],
        Tags=[{'Key': 'Name', 'Value': 'subred-privada-karim'}]
    )
    
    # Habilitar asignación automática de IP pública en subred pública
    ec2.modify_subnet_attribute(
        SubnetId=subnet_pub_id,
        MapPublicIpOnLaunch={'Value': True}
    )
    print("IP pública automática habilitada en subred pública")
    
    return subnet_pub_id, subnet_priv_id


def crear_internet_gateway(ec2, vpc_id):
    """Crea un Internet Gateway y lo asocia a la VPC."""
    print("3. Creando Internet Gateway...")
    
    # Crear Internet Gateway
    igw = ec2.create_internet_gateway()
    igw_id = igw['InternetGateway']['InternetGatewayId']
    print(f"Internet Gateway creado: {igw_id}")
    
    # Etiquetar Internet Gateway
    ec2.create_tags(
        Resources=[igw_id],
        Tags=[{'Key': 'Name', 'Value': 'igw-karim'}]
    )
    
    # Asociar Internet Gateway a la VPC
    ec2.attach_internet_gateway(
        InternetGatewayId=igw_id,
        VpcId=vpc_id
    )
    print("Internet Gateway asociado a la VPC")
    
    return igw_id


def crear_tablas_enrutamiento(ec2, vpc_id, subnet_pub_id, subnet_priv_id, igw_id):
    """Crea tablas de enrutamiento para subredes pública y privada."""
    print("4. Creando tablas de enrutamiento...")
    
    # Crear tabla de enrutamiento pública
    rt_pub = ec2.create_route_table(VpcId=vpc_id)
    rt_pub_id = rt_pub['RouteTable']['RouteTableId']
    print(f"Tabla de enrutamiento pública: {rt_pub_id}")
    
    # Etiquetar tabla de enrutamiento pública
    ec2.create_tags(
        Resources=[rt_pub_id],
        Tags=[{'Key': 'Name', 'Value': 'rt-publica-karim'}]
    )
    
    # Crear tabla de enrutamiento privada
    rt_priv = ec2.create_route_table(VpcId=vpc_id)
    rt_priv_id = rt_priv['RouteTable']['RouteTableId']
    print(f"Tabla de enrutamiento privada: {rt_priv_id}")
    
    # Etiquetar tabla de enrutamiento privada
    ec2.create_tags(
        Resources=[rt_priv_id],
        Tags=[{'Key': 'Name', 'Value': 'rt-privada-karim'}]
    )
    
    # Asociar subred pública a tabla de enrutamiento pública
    ec2.associate_route_table(
        SubnetId=subnet_pub_id,
        RouteTableId=rt_pub_id
    )
    print("Subred pública asociada a tabla de enrutamiento pública")
    
    # Asociar subred privada a tabla de enrutamiento privada
    ec2.associate_route_table(
        SubnetId=subnet_priv_id,
        RouteTableId=rt_priv_id
    )
    print("Subred privada asociada a tabla de enrutamiento privada")
    
    # Crear ruta a Internet en tabla pública
    ec2.create_route(
        RouteTableId=rt_pub_id,
        DestinationCidrBlock='0.0.0.0/0',
        GatewayId=igw_id
    )
    print("Ruta a Internet Gateway creada en tabla pública")
    
    return rt_pub_id, rt_priv_id


if __name__ == "__main__":
    # Crear cliente de EC2
    ec2 = boto3.client('ec2')
    
    print("=== INICIANDO CREACIÓN DE INFRAESTRUCTURA ===\n")
    
    # Ejecutar funciones en orden
    vpc_id = crear_vpc(ec2)
    subnet_pub_id, subnet_priv_id = crear_subredes(ec2, vpc_id)
    igw_id = crear_internet_gateway(ec2, vpc_id)
    rt_pub_id, rt_priv_id = crear_tablas_enrutamiento(ec2, vpc_id, subnet_pub_id, subnet_priv_id, igw_id)
    
    print("\n=== RESUMEN DE RECURSOS CREADOS ===")
    print(f"VPC ID: {vpc_id}")
    print(f"Subred Pública: {subnet_pub_id}")
    print(f"Subred Privada: {subnet_priv_id}")
    print(f"Internet Gateway: {igw_id}")
    print(f"Tabla de Enrutamiento Pública: {rt_pub_id}")
    print(f"Tabla de Enrutamiento Privada: {rt_priv_id}")