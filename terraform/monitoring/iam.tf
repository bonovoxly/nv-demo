# data "aws_secretsmanager_secret" "saints-xctf-andy-password" {
#   name = "saints-xctf-andy-password"
# }

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "_" {
  name = "${var.env}-canary-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  description = "${var.env} IAM role for AWS Synthetic Monitoring Canaries"
}

data "aws_iam_policy_document" "_" {
  statement {
    sid = "CanaryGeneric"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "_" {
  name = "${var.env}-canary-policy"
  policy = data.aws_iam_policy_document._.json
  description = "${var.env} IAM policy for AWS Synthetic Monitoring Canaries"
}

resource "aws_iam_role_policy_attachment" "_" {
  role = aws_iam_role._.name
  policy_arn = aws_iam_policy._.arn
}