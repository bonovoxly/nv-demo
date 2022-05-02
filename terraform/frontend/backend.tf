terraform {
  backend "s3" {
    bucket = "nv-demo-terraform-state"
    key    = "frontend/terraform.tfstate"
    region = "us-east-1"
  }
}
