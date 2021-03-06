# VPC lookup
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

data "aws_secretsmanager_secret_version" "postgres" {
  secret_id = "postgres"
}