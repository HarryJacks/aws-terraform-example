# AWS Terraform Example (Node.js) 🚀

I challenged myself today to try and get an AWS API Gateway endpoint calling an AWS Lambda, all running locally in Docker and configured with Terraform!

## Installation

Ensure that Localstack, Docker and Terraform are installed. (aws-cli is also needed for the shell scripts).

## Usage
```bash
localstack start

terraform init

terraform plan

terraform apply --auto-approve
```
You should then be able to hit the POST endpoint like this:

```bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"name":"Harry Jacks"}' \
  http://localhost:4566/restapis/<rest-api-id>/test/_user_request_/hello
```

The **<rest-api-id>** needed in the script above can be found by running this shell script:
```bash
# Give script permission to run
chmod +x /<your-file-path-goes-here>/aws-terraform-example/scripts/list-api-gateway-endpoints.sh

# Run script
/<your-file-path-goes-here>/aws-terraform-example/scripts/list-api-gateway-endpoints.sh
```

The above example will show any api gateway endpoints that are registered in our Localstack container in Docker.

### Author
Harry Jacks (H Jacks Ltd) - Full stack JavaScript Engineer.
