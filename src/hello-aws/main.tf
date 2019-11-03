#Variables declaradas en terraform.tfvars
variable "stage_demo" {}
variable "last_path_segment" {}
variable "name_storage" {}
variable "name_role" {}
variable "name_function" {}
variable "name_apirest" {}

#Comprension de contenido 
data "archive_file" "http_trigger" {
  type        = "zip"
  output_path = "${path.module}/http_trigger.zip"
  source {
    content  = "${file("${path.module}/http_trigger.js")}"
    filename = "main.js"
  }
}

#1) Creación de Storage
resource "aws_s3_bucket" "aws_bucket" {
  bucket = "${var.name_storage}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

#2)Objeto que sera enviado al S3
resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.aws_bucket.bucket}"
  key    = "v1.0.0/http_trigger.zip"
  source = "${path.module}/http_trigger.zip"
  depends_on = ["data.archive_file.http_trigger"]
}
#3) Creacion de Rol de ejecución
resource "aws_iam_role" "lambda_execute" {
  name = "${var.name_role}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
#4) Creación de la funcion lambda
resource "aws_lambda_function" "MyDemo" {
  function_name = "${var.name_function}"
  s3_bucket = "${aws_s3_bucket.aws_bucket.bucket}"
  s3_key    = "v1.0.0/http_trigger.zip"
  handler = "main.handler"
  runtime = "nodejs10.x"
  role = "${aws_iam_role.lambda_execute.arn}"
}
#5) Creacion del api rest
resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "${var.name_apirest}"
  description = "Demo para AWS Community Day"
}
#6) Creación de un recurso
resource "aws_api_gateway_resource" "MyDemoResource" {
  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.MyDemoAPI.root_resource_id}"
  path_part   = "${var.last_path_segment}" //Variable que contiene "Welcome"
}
#7) Creación de un metodo
resource "aws_api_gateway_method" "MyDemoMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  resource_id   = "${aws_api_gateway_resource.MyDemoResource.id}"
  http_method   = "GET"
  authorization = "NONE"
}
#8) Creación de la integración
resource "aws_api_gateway_integration" "MyDemoIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  resource_id = "${aws_api_gateway_resource.MyDemoResource.id}"
  http_method = "${aws_api_gateway_method.MyDemoMethod.http_method}"
  integration_http_method = "POST" // las funciones lambda solo se pueden invocar a traves de POST
  type                    = "AWS_PROXY" //para integracion con LAMBDA_PROXY
  uri                     = "${aws_lambda_function.MyDemo.invoke_arn}"
}

resource "aws_api_gateway_deployment" "MyDemoDeployment" {
  depends_on = ["aws_api_gateway_integration.MyDemoIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  stage_name  = "${var.stage_demo}" 
}
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.MyDemo.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_deployment.MyDemoDeployment.execution_arn}/*/${var.last_path_segment}"
}

resource "aws_vpc" "vpc_demo" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demoaws"
  }
}
