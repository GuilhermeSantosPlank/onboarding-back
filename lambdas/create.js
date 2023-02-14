const AWS = require("aws-sdk");
const crypto = require('crypto');
const ONBOARDING_TABLE = process.env.ONBOARDING_TABLE;

const documentClient = new AWS.DynamoDB.DocumentClient();

module.exports.handler = async (event, context) => {
	try {
		const body = JSON.parse(event.body);
		const requiredFields = [
			"tag",
			"value",
			"type"
		];

		for (const field of requiredFields) {
			if (!body[field]) {
				return {
					statusCode: 400,
					body: `Missing param: ${field}`
				};
			}
		}

		const { tag, value, type } = body;

		const newItem = {
			id: crypto.randomUUID(),
			tag,
			value,
			type,
			timestamp: Date.now(),
		};

		await documentClient
			.put({
				TableName: ONBOARDING_TABLE,
				Item: newItem,
			})
			.promise();

		return {
			statusCode: 200,
			body: JSON.stringify(newItem),
		};
	} catch (err) {
		return {
			statusCode: 500,
			body: "Internal server error"
		};
	}
};

