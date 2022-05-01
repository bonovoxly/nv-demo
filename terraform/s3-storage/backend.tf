terraform {
  backend "s3" {
    bucket = "nv-demo-terraform-state"
    key    = "storage/terraform.tfstate"
    region = "us-east-1"
  }
}
