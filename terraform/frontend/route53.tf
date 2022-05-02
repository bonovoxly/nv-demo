resource "aws_route53_record" "_" {
  name    = "${var.env}.${var.domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.zone.zone_id
  alias {
    name                   = module.api_gateway.apigatewayv2_domain_name_target_domain_name
    zone_id                = module.api_gateway.apigatewayv2_domain_name_hosted_zone_id
    evaluate_target_health = false
  }
}
