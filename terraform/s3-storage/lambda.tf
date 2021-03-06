module "postgres-update" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.env}-postgres-update"
  description   = "Updates postgres with S3 files"
  handler       = "postgres-update.lambda_handler"
  runtime       = "python3.6"
  publish       = true
  maximum_retry_attempts = 6
  vpc_subnet_ids         = [data.aws_subnet.a-private.id, data.aws_subnet.b-private.id, data.aws_subnet.c-private.id]
  vpc_security_group_ids = [module.postgres_update_security_group.security_group_id]
  attach_network_policy = true
  source_path = [ 
  "../../src/postgres-update",
  {
    path = "../../src/postgres-update",
    pip_requirements = "../../requirements.txt",
  }
]
  timeout = 6

  cloudwatch_logs_retention_in_days = 7

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
              "${data.aws_secretsmanager_secret_version.postgres.arn}"
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

module "postgres_update_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.env}-postgres-update"
  description = "nv-demo postgres-update security group"
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
