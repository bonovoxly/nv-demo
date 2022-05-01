module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.env
  cidr = "${var.cidr_prefix}.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["${var.cidr_prefix}.10.0/24", "${var.cidr_prefix}.11.0/24", "${var.cidr_prefix}.12.0/24"]
  public_subnets  = ["${var.cidr_prefix}.0.0/24", "${var.cidr_prefix}.1.0/24", "${var.cidr_prefix}.2.0/24"]
  database_subnets = ["${var.cidr_prefix}.20.0/24", "${var.cidr_prefix}.21.0/24", "${var.cidr_prefix}.22.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_dhcp_options  = true
  enable_vpn_gateway   = false

  # database config
  create_database_subnet_group           = false
  create_database_subnet_route_table     = false
  create_database_internet_gateway_route = false

  tags = {
    Terraform   = "true"
    Environment = var.env
    Github      = var.github
  }
}

