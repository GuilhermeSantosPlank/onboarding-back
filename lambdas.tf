# Role for Lambdas
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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
        "Resource" : "${aws_dynamodb_table.onboarding_table.arn}"
      }
    ]
  })
}


# Lambdas
data "archive_file" "create-archive" {
  source_file = "lambdas/create.js"
  output_path = "lambdas/create.zip"
  type        = "zip"
}

# Lambdas
data "archive_file" "create-archive_get_all" {
  source_file = "lambdas/get_all.js"
  output_path = "lambdas/get_all.zip"
  type        = "zip"
}

resource "aws_lambda_function" "get_all" {
  environment {
    variables = {
      ONBOARDING_TABLE = aws_dynamodb_table.onboarding_table.name
    }
  }
  memory_size   = "128"
  timeout       = 10
  runtime       = "nodejs14.x"
  architectures = ["arm64"]
  handler       = "lambdas/get_all.handler"
  function_name = "get_all"
  role          = aws_iam_role.iam_for_lambda.arn
  filename      = "lambdas/get_all.zip"
}

# Lambdas
data "archive_file" "create-archive_delete" {
  source_file = "lambdas/delete.js"
  output_path = "lambdas/delete.zip"
  type        = "zip"
}

resource "aws_lambda_function" "delete" {
  environment {
    variables = {
      ONBOARDING_TABLE = aws_dynamodb_table.onboarding_table.name
    }
  }
  memory_size   = "128"
  timeout       = 10
  runtime       = "nodejs14.x"
  architectures = ["arm64"]
  handler       = "lambdas/delete.handler"
  function_name = "delete"
  role          = aws_iam_role.iam_for_lambda.arn
  filename      = "lambdas/delete.zip"
}

resource "aws_lambda_function" "create" {
  environment {
    variables = {
      ONBOARDING_TABLE = aws_dynamodb_table.onboarding_table.name
    }
  }
  memory_size   = "128"
  timeout       = 10
  runtime       = "nodejs14.x"
  architectures = ["arm64"]
  handler       = "lambdas/create.handler"
  function_name = "create"
  role          = aws_iam_role.iam_for_lambda.arn
  filename      = "lambdas/create.zip"
}

resource "aws_lambda_permission" "api_create" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:235335160924:*/*"
}

resource "aws_lambda_permission" "api_get_all" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_all.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:235335160924:*/*"
}

resource "aws_lambda_permission" "api_delete" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:235335160924:*/*"
}