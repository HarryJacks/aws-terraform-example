const aws = require('aws-sdk');

exports.hello = async (event) => {
    const parsedName = JSON.parse(event.body).name;
    const response = {
        statusCode: 200,
        body: JSON.stringify(`Hello ${parsedName}!`),
    };
    return response;
}