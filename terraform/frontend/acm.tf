module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.2.0"
  domain_name = "${var.env}.${var.domain}"
  zone_id     = data.aws_route53_zone.zone.zone_id
  subject_alternative_names = [
    "*.${var.env}.${var.domain}"
  ]
  wait_for_validation = true
  tags = local.tags
}
