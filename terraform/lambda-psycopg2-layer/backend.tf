terraform {
  backend "s3" {
    bucket = "nv-demo-terraform-state"
    key    = "lambda-psycopg2-layer/terraform.tfstate"
    region = "us-east-1"
  }
}
