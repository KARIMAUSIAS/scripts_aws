import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    //construct l1 s3 bucket
    /*new cdk.aws_s3.CfnBucket(this, 'MyFirstBucket', {
      bucketName: 'my-first-bucket-krm1234567'
    });*/

    //construct l2 s3 bucket
    const bucket = new cdk.aws_s3.Bucket(this, 'MyFirstBucket', {
      bucketName: 'my-first-bucket-krm123456743'
    });

    //subir un archivo al bucket ya creado
    new cdk.aws_s3_deployment.BucketDeployment(this, 'DeployFiles', {
      sources: [cdk.aws_s3_deployment.Source.asset('./assets')],
      destinationBucket: bucket
    });

  }
}
