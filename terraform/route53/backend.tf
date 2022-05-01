terraform {
  backend "s3" {
    bucket = "nv-demo-terraform-state"
    key    = "route53/terraform.tfstate"
    region = "us-east-1"
  }
}
