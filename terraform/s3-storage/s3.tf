
resource "aws_s3_bucket" "_" {
  bucket = "nv-demo-storage"
}

resource "aws_s3_bucket_lifecycle_configuration" "_" {
  bucket = aws_s3_bucket._.id
  rule {
    id = "rule-1"
    filter {}
    expiration {
      days = var.retention_period
    }
    status = "Enabled"
}
}
resource "aws_s3_bucket_acl" "_" {
  bucket = aws_s3_bucket._.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "_" {
  bucket = aws_s3_bucket._.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_notification" "_" {
  bucket = "${var.env}-storage"

  lambda_function {
    lambda_function_arn = module.postgres-update.lambda_function_arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

resource "aws_lambda_permission" "_" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.postgres-update.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.env}-storage"
}