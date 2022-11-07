# AWS Terraform Example (Node.js) 🚀

I challenged myself today to try and get an AWS API Gateway endpoint calling an AWS Lambda, all running locally in Docker and configured with Terraform! I've since added a DynamoDB with some dummy data and now we can POST data to the API, it then calls the Lambda, which puts the data into the table in the database.

## Installation

Ensure that Localstack, Docker and Terraform are installed. (aws-cli is also needed for the shell scripts).

## Setup
Zip up the 'contents' of the /lambda-src folder (not the folder itself) and call it 'index.zip'. Put this zip file at the root of the project before running the commands below.

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
  --data '{"name":"Neville","number":"12","age":23}' \
  http://localhost:4566/restapis/<rest-api-id>/test/_user_request_/create_england98_player
```

The **rest-api-id** needed in the script above can be found by running this shell script:
```bash
# Give script permission to run
chmod +x /<your-file-path-goes-here>/aws-terraform-example/scripts/list-api-gateway-endpoints.sh

# Run script
/<your-file-path-goes-here>/aws-terraform-example/scripts/list-api-gateway-endpoints.sh
```

The above example will show any api gateway endpoints that are registered in our Localstack container in Docker.

### Author
Harry Jacks (H Jacks Ltd) - Full stack JavaScript Engineer.
