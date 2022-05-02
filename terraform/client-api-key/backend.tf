terraform {
  backend "s3" {
    bucket = "nv-demo-terraform-state"
    key    = "client-api-key/terraform.tfstate"
    region = "us-east-1"
  }
}
