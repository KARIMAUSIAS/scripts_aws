import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as lambda from 'aws-cdk-lib/aws-lambda';

export class Cdk2Stack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // ─── Lambda función inline (Node.js 20) ───────────────────────────────────
    const helloFn = new lambda.Function(this, 'HelloFunction', {
      functionName: 'hello-handler',
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
      code: lambda.Code.fromInline(`
exports.handler = async () => ({
  statusCode: 200,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ message: 'Hello from CDK L2!' }),
});`),
    });

    // ─── REST API con integración proxy automática ────────────────────────────
    const restApi = new apigateway.RestApi(this, 'HelloRestApi', {
      restApiName: 'HelloApi',
      description: 'API REST desplegada con constructores L2',
      deployOptions: {
        stageName: 'produc',  // Stage personalizado
      },
    });

    // ─── Ruta /hello con GET (proxy automático) ───────────────────────────────
    const helloResource = restApi.root.addResource('hello');
    helloResource.addMethod('GET', new apigateway.LambdaIntegration(helloFn));

    // ─── Output con el endpoint público ───────────────────────────────────────
    new cdk.CfnOutput(this, 'HelloEndpoint', {
      description: 'Endpoint público — prueba con: curl <URL>',
      value: `${restApi.url}produc/hello`,
    });
  }
}
