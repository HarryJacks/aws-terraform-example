const AWS = require('aws-sdk');

const serviceConfigOptions = {
    region: "ap-northeast-2",
    endpoint: `${process.env.LOCALSTACK_HOSTNAME}:4566`,
    
  };

const ddb = new AWS.DynamoDB.DocumentClient(serviceConfigOptions);

exports.create_england98_player = async (event) => {
    const parsedName = JSON.parse(event.body).name;
    const parsedNumber = JSON.parse(event.body).number;
    const parsedAge = JSON.parse(event.body).age;

    const params = {
        TableName: 'England98',
        Item: {
            PlayerName: parsedName,
            SquadNumber: parsedNumber,
            Age: parsedAge ? parsedAge : null
        }
    }

    let response = {
        statusCode: 200,
        body: '',
    };

    try {
        const result = await ddb.put(params).promise();
        console.log("SUCCESS");
        response.statusCode = 200;
        response.body = JSON.stringify(result);
        return response;
    } catch(err) {
        console.log(err);
        response.statusCode = err.statusCode;
        response.body = JSON.stringify(err);
        return response;
    }

}