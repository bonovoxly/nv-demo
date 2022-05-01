# the environment
variable "env" {
  type    = string
  default = "nv-demo"
}

# the VPC CIDR prefix to use. For instance, '10.22' creates a VPC with 10.22.0.0/16
variable "cidr_prefix" {
  type    = string
  default = "10.23"
}

# AWS region
variable "region" {
  type    = string
  default = "us-east-1"
}

# GitHub
variable "github" {
  type    = string
  default = "https://github.com/bonovoxly/nv-demo"
}

