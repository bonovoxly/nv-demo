terraform {
  backend "s3" {
    bucket = "nv-demo-terraform-state"
    key    = "monitoring/terraform.tfstate"
    region = "us-east-1"
  }
}
