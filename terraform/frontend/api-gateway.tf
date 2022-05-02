resource "aws_cloudwatch_log_group" "api_gateway" {
  name = "${var.env}-apigateway"
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"
  name          = var.env
  description   = "${var.env} API gateway"
  # Custom domain
  create_api_domain_name      = true
  domain_name                 = "${var.env}.${var.domain}"
  domain_name_certificate_arn = module.acm.acm_certificate_arn
  protocol_type = "HTTP"
  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.api_gateway.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"
  default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }

  # authorizers = {
  #   "lambda" = {
  #     authorizer_type  = "REQUEST"
  #     identity_sources = "$request.header.Authorization"
  #     name             = "lambda-authorizer"
  #     authorizer_payload_format_version = "2.0"
  #     authorizer_uri   = module.lambda-authorizer.lambda_function_invoke_arn
      
  #   }
  # }

  integrations = {
    "GET /api/list" = {
      lambda_arn             = module.api_lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 30000
      authorization_type     = "CUSTOM"
      authorizer_id = aws_apigatewayv2_authorizer._.id
      authorization_scopes = ""
      # authorizer_key          = "lambda"
    }
    "PUT /api/upload/{proxy+}" = {
      lambda_arn             = module.api_lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 30000
      authorization_type     = "CUSTOM"
      authorizer_id = aws_apigatewayv2_authorizer._.id
      authorization_scopes = ""
      # authorizer_key          = "lambda"
    }
    "GET /api/upload_presigned/{proxy+}" = {
      lambda_arn             = module.api_lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 30000
      authorization_type     = "CUSTOM"
      authorizer_id = aws_apigatewayv2_authorizer._.id
      authorization_scopes = ""
      # authorizer_key          = "lambda"
    }
    "GET /api/download_presigned/{proxy+}" = {
      lambda_arn             = module.api_lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 30000
      authorization_type     = "CUSTOM"
      authorizer_id = aws_apigatewayv2_authorizer._.id
      authorization_scopes = ""
      # authorizer_key          = "lambda"
    }
    "GET /{proxy+}" = {
      lambda_arn             = module.api_lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 30000
      authorization_type     = "CUSTOM"
      authorizer_id = aws_apigatewayv2_authorizer._.id
      authorization_scopes = ""
      # authorizer_key          = "lambda"
    }
    "GET /" = {
      lambda_arn             = module.api_lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 30000
      # authorization_type     = "CUSTOM"
      # authorizer_id = aws_apigatewayv2_authorizer._.id
      # authorization_scopes = ""
      # authorizer_key          = "lambda"
    }
    "$default" = {
      lambda_arn = module.api_lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 30000
      authorization_type     = "CUSTOM"
      authorizer_id = aws_apigatewayv2_authorizer._.id
      authorization_scopes = ""
      # authorizer_key          = "lambda"
    }
  }
  tags = local.tags
}

# # Create S3 Full Access Policy
# resource "aws_iam_policy" "api_gateway_s3_policy" {
#   name        = "${var.env}-api-gateway-s3-policy"
#   description = "Policy for allowing all S3 Actions"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "ListObjectsInBucket",
#             "Effect": "Allow",
#             "Action": ["s3:ListBucket"],
#             "Resource": ["arn:aws:s3:::${var.env}-storage"]
#         },
#         {
#             "Sid": "AllObjectActions",
#             "Effect": "Allow",
#             "Action": "s3:*Object",
#             "Resource": ["arn:aws:s3:::${var.env}-storage/*"]
#         }
#     ]
# }
# EOF
# }

# # Create API Gateway Role
# resource "aws_iam_role" "api_gateway_s3_role" {
#   name = "${var.env}-api-gateway-s3-role"

#   # Create Trust Policy for API Gateway
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "apigateway.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# } 
#   EOF
# }

# # Attach S3 Access Policy to the API Gateway Role
# resource "aws_iam_role_policy_attachment" "api_gateway_s3_attach" {
#   role       = aws_iam_role.api_gateway_s3_role.name
#   policy_arn = aws_iam_policy.api_gateway_s3_policy.arn
# }
