data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.env]
  }
}

data "aws_subnet" "a-private" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-private-${var.region}a"]
  }
}

data "aws_subnet" "b-private" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-private-${var.region}b"]
  }
}

data "aws_subnet" "c-private" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-private-${var.region}c"]
  }
}

data "aws_subnet" "a-db" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-db-${var.region}a"]
  }
}

data "aws_subnet" "b-db" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-db-${var.region}b"]
  }
}

data "aws_subnet" "c-db" {
  filter {
    name   = "tag:Name"
    values = ["${var.env}-db-${var.region}c"]
  }
}

data "archive_file" "_" {
  type = "zip"
  source {
    content  = templatefile("../../src/canary/canary.tftpl",
      { 
        env = var.env
        domain = var.domain 
      }
    )
    filename = "python/canary.py" 
  }
  // canary resource will not detect if file content has changed. So include hash in filename.
  output_path = "${path.root}/canary-${filemd5("../../src/canary/canary.tftpl")}.zip"
}
