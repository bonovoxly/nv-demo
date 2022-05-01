# the environment
variable "env" {
  type    = string
  default = "nv-demo"
}

# AWS region
variable "region" {
  type    = string
  default = "us-east-1"
}

# S3 retention period
variable "retention_period" {
  type    = number
  default = 30
}

# GitHub
variable "github" {
  type    = string
  default = "https://github.com/bonovoxly/nv-demo"
}

