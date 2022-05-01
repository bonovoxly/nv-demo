terraform {
  backend "s3" {
    bucket = "nv-demo-terraform-state"
    key    = "secrets/terraform.tfstate"
    region = "us-east-1"
  }
}
