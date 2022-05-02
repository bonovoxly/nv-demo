# the environment
variable "env" {
  type    = string
  default = "nv-demo"
}

variable "client_api_key" {
  type = string
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

