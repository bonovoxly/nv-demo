terraform {
  backend "s3" {
    bucket = "nv-demo-terraform-state"
    key    = "elasticache/terraform.tfstate"
    region = "us-east-1"
  }
}
