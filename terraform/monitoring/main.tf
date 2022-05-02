resource "aws_synthetics_canary" "_" {
  name                 = "${var.env}-canary"
  artifact_s3_location = "s3://${var.env}-canary/"
  execution_role_arn   = aws_iam_role._.arn
  handler              = "canary.handler"
  zip_file             = data.archive_file._.output_path
  runtime_version      = "syn-python-selenium-1.2"
  start_canary = true

  schedule {
    expression = "rate(5 minutes)"
  }
}
