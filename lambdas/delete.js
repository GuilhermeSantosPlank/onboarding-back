const AWS = require("aws-sdk"); 
const ONBOARDING_TABLE = process.env.ONBOARDING_TABLE; 

const documentClient = new AWS.DynamoDB.DocumentClient();

module.exports.handler = async (event, context) => {
	try{
		if (!event.pathParameters && !event.pathParameters.id) {
			return {
				statusCode: 400,
				body: `Missing path param: id`
			};
		}

		var id = event.pathParameters.id;
		
		var params = {
			TableName : ONBOARDING_TABLE,
			Key: {
			  HashKey: {id: id},
			  NumberRangeKey: 1
			}
		};

		await documentClient
		  .delete(params)
		  .promise();
		return {
			statusCode: 204
		};
	} catch(err){
		return {
			statusCode: 500,
			body: JSON.stringify(err)
		};
	}
};

