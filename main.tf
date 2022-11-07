// Resource: IAM
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

// Resource: Lambda
resource "aws_lambda_function" "create_england98_player" {
  filename = "index.zip"
  function_name = "create_england98_player"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "index.create_england98_player"
  source_code_hash = filebase64sha256("index.zip")
  runtime = "nodejs16.x"

  environment {
    variables = {
        foo = "bar"
    }
  }
}

// Resource: API Gateway
resource "aws_api_gateway_rest_api" "api_gw" {
    name = "Example API Gateway"
    description = "API gateway v1"
}

resource "aws_api_gateway_resource" "create_england98_player" {
    rest_api_id = aws_api_gateway_rest_api.api_gw.id
    parent_id = aws_api_gateway_rest_api.api_gw.root_resource_id
    path_part   = "create_england98_player"
}

resource "aws_api_gateway_method" "create_england98_player" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  resource_id = aws_api_gateway_resource.create_england98_player.id
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  resource_id = aws_api_gateway_method.create_england98_player.resource_id
  http_method = aws_api_gateway_method.create_england98_player.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.create_england98_player.invoke_arn
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
  function_name = aws_lambda_function.create_england98_player.function_name
  principal = "apigateway.amazonaws.com"
  source_arn =  "${aws_api_gateway_rest_api.api_gw.execution_arn}/*/*"
}

// Resource: DynamoDB
resource "aws_dynamodb_table" "england_98_table" {
  name             = "England98"
  billing_mode     = "PROVISIONED"
  read_capacity    = 1
  write_capacity   = 1 
  hash_key         = "PlayerName"
  
  attribute {
    name = "PlayerName"
    type = "S"
  }
  
  attribute {
    name = "SquadNumber"
    type = "S"
  }
  global_secondary_index {
    name               = "SquadNumber-Index"
    hash_key           = "SquadNumber"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "INCLUDE"
    non_key_attributes = ["Age"]
  }
  tags = {
    Name        = "england-98-table"
    Environment = "test"
  }
}

resource "aws_iam_role_policy" "dynamodb-lambda-policy" {
   name = "dynamodb_lambda_policy"
   role = aws_iam_role.iam_for_lambda.id
   policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
           "Effect" : "Allow",
           "Action" : ["dynamodb:*"],
           "Resource" : "${aws_dynamodb_table.england_98_table.arn}"
        }
      ]
   })
}

// Create DynamoDB Add Multiple Items to England98 
resource "aws_dynamodb_table_item" "england_98_items" {
  table_name = aws_dynamodb_table.england_98_table.name
  hash_key   = aws_dynamodb_table.england_98_table.hash_key
  
  for_each = {
    "Seaman" = {
      squadNumber = "1"
      age  = 34
    }
    "Shearer" = {
      squadNumber = "9"
      age  = 27    
    }
    "Beckham" = {
      squadNumber = "7"
      age  = 23    
    }
  }
  item = <<ITEM
 {
    "PlayerName": {"S": "${each.key}"},
    "SquadNumber": {"S": "${each.value.squadNumber}"},
    "Age": {"N": "${each.value.age}"}
  }
  ITEM
}