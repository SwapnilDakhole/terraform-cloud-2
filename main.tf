provider "aws" {
  region = "ap-south-1"
}


# Create an IAM Role for Lambda
resource "aws_iam_role" "spring_lambda_role" {
  name = "terraform_spring_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach AWSLambdaBasicExecutionRole policy for logging
resource "aws_iam_role_policy_attachment" "spring_lambda_logs" {
  role       = aws_iam_role.spring_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



# Create the Lambda function
resource "aws_lambda_function" "spring_lambda" {
  function_name    = "SpringBootLambdaFunction"
  role            = aws_iam_role.spring_lambda_role.arn
  handler         = "com.deals_migration.DealsMigrationHandler::handleRequest"
  runtime         = "java17"
  timeout         = 30
  memory_size     = 1024

  filename        = "${path.module}/java/assignment-0.0.1-SNAPSHOT-lambda-package.zip"
  source_code_hash = filebase64sha256("${path.module}/java/assignment-0.0.1-SNAPSHOT-lambda-package.zip")

  depends_on      = [aws_iam_role_policy_attachment.spring_lambda_logs]
}

output "lambda_function_name" {
  value = aws_lambda_function.spring_lambda.function_name
}
