aws elasticbeanstalk create-application --application-name blue-green-app-karim

aws s3 cp archivos/blue.zip s3://s3-ebs-karim/blue.zip

aws s3 cp archivos/green.zip s3://s3-ebs-karim/green.zip

aws elasticbeanstalk create-application-version --application-name blue-green-app-karim \
    --version-label blue-v1 \
    --source-bundle S3Bucket=s3-ebs-karim,S3Key=blue.zip

aws elasticbeanstalk create-application-version --application-name blue-green-app-karim \
    --version-label green-v2 \
    --source-bundle S3Bucket=s3-ebs-karim,S3Key=green.zip

aws elasticbeanstalk create-environment \
    --application-name blue-green-app-karim \
    --environment-name blue-env \
    --version-label blue-v1 \
    --solution-stack-name "64bit Amazon Linux 2023 V4.7.8 running PHP 8.4" \
    --option-settings \
   Namespace=aws:autoscaling:launchconfiguration,OptionName=IamInstanceProfile,Value=LabInstanceProfile \
   Namespace=aws:elasticbeanstalk:environment,OptionName=ServiceRole,Value=LabRole \
   Namespace=aws:autoscaling:launchconfiguration,OptionName=EC2KeyName,Value=vockey

aws elasticbeanstalk create-environment \
    --application-name blue-green-app-karim \
    --environment-name green-env \
    --version-label green-v2 \
    --solution-stack-name "64bit Amazon Linux 2023 V4.7.8 running PHP 8.4" \
    --option-settings \
   Namespace=aws:autoscaling:launchconfiguration,OptionName=IamInstanceProfile,Value=LabInstanceProfile \
   Namespace=aws:elasticbeanstalk:environment,OptionName=ServiceRole,Value=LabRole \
   Namespace=aws:autoscaling:launchconfiguration,OptionName=EC2KeyName,Value=vockey

aws elasticbeanstalk swap-environment-cnames \
  --source-environment-name green-env \
  --destination-environment-name blue-env
