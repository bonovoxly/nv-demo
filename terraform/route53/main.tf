resource "aws_route53_zone" "_" {
  name = "nv.lfc.sh"
}


resource "aws_route53_record" "mrtest" {
  zone_id = aws_route53_zone._.zone_id
  name    = "mrtest"
  type    = "A"
  ttl     = "60"
  records = ["10.1.2.3"]
}

