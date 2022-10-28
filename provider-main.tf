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
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  s3_force_path_style = false
  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_requesting_account_id = true

  endpoints {
    apigateway = "http://localhost:4566"
    iam = "http://localhost:4566"
    s3 = "http://s3.localhost.localstack.cloud:4566"
    lambda = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
  }
}