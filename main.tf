terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3"
    }
  }
}

# Configure the aws provider
provider "aws" {
  region = "ap-northeast-2"
  access_key = "test"
  secret_key = "test"
  s3_force_path_style = false
  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_requesting_account_id = true

  endpoints {
    apigateway = "http://localhost:4566"
    iam = "http://localhost:4566"
    s3 = "http://s3.localhost.localstack.cloud:4566"
    lambda = "http://localhost:4566"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"

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

resource "aws_lambda_function" "hello" {
  filename = "index.zip"
  function_name = "hello"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "index.hello"
  source_code_hash = filebase64sha256("index.zip")
  runtime = "nodejs16.x"

  environment {
    variables = {
        foo = "bar"
    }
  }
}

resource "aws_api_gateway_rest_api" "api_gw" {
    name = "Example API Gateway"
    description = "API gateway v1"
}

resource "aws_api_gateway_resource" "proxy" {
    rest_api_id = aws_api_gateway_rest_api.api_gw.id
    parent_id = aws_api_gateway_rest_api.api_gw.root_resource_id
    path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.hello.invoke_arn
}

resource "aws_api_gateway_deployment" "apigw_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda
  ]
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  stage_name = "test"
}

resource "aws_lambda_permission" "apigw" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello.function_name
  principal = "apigateway.amazonaws.com"
  source_arn =  "${aws_api_gateway_rest_api.api_gw.execution_arn}/*/*"
}