const AWS = require("aws-sdk");
const ONBOARDING_TABLE = process.env.ONBOARDING_TABLE; 

const documentClient = new AWS.DynamoDB.DocumentClient();

module.exports.handler = async (event, context) => {
	try{
		var params = {
			TableName : ONBOARDING_TABLE
		};

		var tags = await documentClient
					.scan(params)
					.promise();
	
		return {
			statusCode: 200,
			body: JSON.stringify(tags.Items)
		};
	} catch(err){
		return {
			statusCode: 500,
			body: JSON.stringify(err)
		};
	}
};

