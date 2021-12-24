# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../lambda"
  output_path = "../dist/lambda_build.zip"
}

resource "aws_lambda_function" "lambda" {

  filename      = "../dist/lambda_build.zip"
  function_name = "portchecker_lambda"
  role          = aws_iam_role.role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  #source_code_hash = filebase64sha256("../dist/lambda_build.zip")
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

