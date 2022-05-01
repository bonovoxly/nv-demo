resource "aws_s3_bucket" "_" {
  bucket = "nv-demo-terraform-state"
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
