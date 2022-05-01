terraform {
  backend "s3" {
    bucket = "nv-demo-terraform-state"
    key    = "postgres/terraform.tfstate"
    region = "us-east-1"
  }
}
