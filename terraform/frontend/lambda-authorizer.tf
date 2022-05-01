module "lambda-authorizer" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.env}-lambda-authorizer"
  description   = "Authorizer for ${var.env} API gateway"
  handler       = "lambda-authorizer.lambda_handler"
  runtime       = "python3.6"
  publish       = true
  maximum_retry_attempts = 6
  vpc_subnet_ids         = [data.aws_subnet.a-private.id, data.aws_subnet.b-private.id, data.aws_subnet.c-private.id]
  vpc_security_group_ids = [module.lambda_authorizer_security_group.security_group_id]
  attach_network_policy = true
  source_path = [ 
    "../../src/lambda-authorizer",
    {
      path = "../../src/lambda-authorizer",
      pip_requirements = "../../requirements.txt",
    }
  ]
  timeout = 6


  environment_variables = {
    DB = replace(var.env, "-", "")
    RDS_HOST = data.aws_db_instance.postgres.address
  }

  attach_policy_json = true
  policy_json = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "secretsmanager:GetSecretValue",
              "secretsmanager:DescribeSecret",
              "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": [
              "${data.aws_secretsmanager_secret_version.client.arn}"
            ]
        }
    ]
}
EOF

  tags = {
    Terraform   = "true"
    Environment = var.env
    Github      = var.github
  }
}

module "lambda_authorizer_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.env}-lambda-authorizer"
  description = "nv-demo lambda-authorizer security group"
  vpc_id      = data.aws_vpc.vpc.id

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = ["::/0"]
  egress_rules       = ["all-all"]

  tags = {
    Terraform   = "true"
    Environment = var.env
    Github      = var.github
  }
}

resource "aws_apigatewayv2_authorizer" "_" {
  api_id           = module.api_gateway.apigatewayv2_api_id
  authorizer_type = "REQUEST"
  identity_sources = ["$request.header.Authorization"]
  name = "${var.env}-lambda-authorizer"
  authorizer_payload_format_version = "2.0"
  authorizer_result_ttl_in_seconds = 300
  enable_simple_responses = true
  authorizer_uri = module.lambda-authorizer.lambda_function_invoke_arn
  authorizer_credentials_arn        = aws_iam_role.api_gateway_lambda_authorizor_role.arn
}

data "aws_iam_policy_document" "apig_lambda_policy" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    effect    = "Allow"
    resources = [module.lambda-authorizer.lambda_function_arn]
    sid       = "ApiGatewayInvokeLambda"
  }
}

data "aws_iam_policy_document" "apig_lambda_role_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_gateway_lambda_authorizor_role" {
  name               = "${var.env}-api-gateway-lambda-authorizer"
  assume_role_policy = data.aws_iam_policy_document.apig_lambda_role_assume.json
}

resource "aws_iam_policy" "apig_lambda" {
  name   = "${var.env}-api-gateway-lambda-authorizer"
  policy = data.aws_iam_policy_document.apig_lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "apig_lambda_role_to_policy" {
  role       = aws_iam_role.api_gateway_lambda_authorizor_role.name
  policy_arn = aws_iam_policy.apig_lambda.arn
}



# resource "aws_iam_role" "authorizer" {
#   name = "${var.env}-lambda-authorizer"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }