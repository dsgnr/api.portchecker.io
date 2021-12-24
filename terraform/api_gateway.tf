# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "devapi.portchecker.io"
  description = "The portchecker.io development API. Managed by Terraform, DO NOT EDIT MANUALLY!"
}

resource "aws_api_gateway_method" "gateway_method" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_rest_api.api.root_resource_id
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.request_validator.id
  request_models = {
    "application/json" = aws_api_gateway_model.api_validation.name
  }
}

resource "aws_api_gateway_request_validator" "request_validator" {
  name                        = "APIValidation"
  rest_api_id                 = aws_api_gateway_rest_api.api.id
  validate_request_body       = true
  validate_request_parameters = false
}

resource "aws_api_gateway_model" "api_validation" {
  rest_api_id  = aws_api_gateway_rest_api.api.id
  name         = "apivalidation"
  description  = "The API validation for api.portchecker.io"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema" : "http://json-schema.org/draft-07/schema#",
  "title" : "Port Checker API",
  "type" : "object",
  "properties" : {
    "host" : {
        "type" : "string",
        "oneOf": [
            {"format": "ipv4"},
            {"format": "ipv6"},
            {"format": "hostname"}
        ]
    },
    "ports" : { "type" : "array" }
  },
  "required": ["host", "ports"]
}
EOF
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_rest_api.api.root_resource_id
  http_method             = aws_api_gateway_method.gateway_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_gateway_response" "gateway_response_400" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  status_code   = "400"
  response_type = "DEFAULT_4XX"
  response_templates = {
    "application/json" = "{\"error\": true, \"message\": $context.error.validationErrorString}"
  }
}

resource "aws_api_gateway_gateway_response" "gateway_response_500" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  status_code   = "500"
  response_type = "DEFAULT_5XX"
  response_templates = {
    "application/json" = "{\"error\": true, \"message\": $context.error.messageString}"
  }
}