terraform {
  backend "s3" {
    bucket = "nv-demo-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}
