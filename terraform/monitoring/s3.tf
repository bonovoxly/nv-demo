resource "aws_s3_bucket" "_" {
  bucket = "${var.env}-canary"
  acl = "private"

  tags = {
    Terraform   = "true"
    Environment = var.env
    Github      = var.github
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "_" {
  bucket = aws_s3_bucket._.id
  rule {
    id = "rule-1"
    filter {}
    expiration {
      days = 30
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

resource "aws_s3_bucket_policy" "_" {
  bucket = aws_s3_bucket._.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id = "canarypolicy"
    Statement = [
      {
        Sid = "Permissions"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action = ["s3:*"]
        Resource = ["${aws_s3_bucket._.arn}/*"]
      }
    ]
  })
}