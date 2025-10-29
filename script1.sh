aws ec2 create-vpc --cidr-block "192.168.0.0/24" \
--instance-tenancy "default" \
--tag-specifications '{"resourceType":"vpc","tags":[{"key":"Name","value":"vpckarim"}]}'

aws ec2 modify-vpc-attribute --vpc-id "preview-vpc-1234" \
--enable-dns-hostnames '{"value":true}' 

aws ec2 describe-vpcs --vpc-ids "preview-vpc-1234" 

aws ec2 create-subnet --vpc-id "preview-vpc-1234" \
--cidr-block "192.168.0.0/28" \
--availability-zone "us-east-1a" \
--tag-specifications '{"resourceType":"subnet","tags":[{"key":"Name","value":"subred1vpckarim"}]}' 

aws ec2 create-internet-gateway \
--tag-specifications '{"resourceType":"internet-gateway","tags":[{"key":"Name","value":"vpckarim-igw"}]}' 

aws ec2 attach-internet-gateway \
--internet-gateway-id "preview-igw-1234" --vpc-id "preview-vpc-1234" 

aws ec2 create-route-table --vpc-id "preview-vpc-1234" 
--tag-specifications '{"resourceType":"route-table","tags":[{"key":"Name","value":"vpckarim-rtb-public"}]}' 

aws ec2 create-route --route-table-id "preview-rtb-public-0" 
--destination-cidr-block "0.0.0.0/0" 
--gateway-id "preview-igw-1234" 

aws ec2 associate-route-table --route-table-id "preview-rtb-public-0" 
--subnet-id "preview-subnet-public-0" 

aws ec2 describe-route-tables  \