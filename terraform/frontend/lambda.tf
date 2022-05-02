module "api_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "v2.35.0"
  timeout = 6
  function_name = "${var.env}-api-lambda"
  description   = "${var.env} API to interact with postgres and files in s3"
  handler       = "api.lambda_handler"
  runtime       = "python3.6"
  publish =true
  vpc_subnet_ids         = [data.aws_subnet.a-private.id, data.aws_subnet.b-private.id, data.aws_subnet.c-private.id]
  vpc_security_group_ids = [module.api_security_group.security_group_id]
  attach_network_policy = true
  source_path = [ 
    "../../src/api",
    {
      path = "../../src/api",
      pip_requirements = "../../requirements.txt",
    }
  ]

  cloudwatch_logs_retention_in_days = 7

  environment_variables = {
    DB = replace(var.env, "-", "")
    RDS_HOST = data.aws_db_instance.postgres.address
    FQDN = "${var.env}.${var.domain}"
    BUCKET = "${var.env}-storage"
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
              "${data.aws_secretsmanager_secret_version.postgres.arn}"
            ]
        },
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["arn:aws:s3:::${var.env}-storage"]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["arn:aws:s3:::${var.env}-storage/*"]
        }
    ]
}
EOF

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }
}

module "api_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.env}-api-lambda"
  description = "nv-demo api lambda security group"
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
