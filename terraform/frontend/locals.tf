locals {
  tags = {
    Terraform   = "true"
    Environment = var.env
    Github      = var.github
  }
}
