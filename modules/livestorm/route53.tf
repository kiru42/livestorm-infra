resource "aws_route53_record" "service_public" {
  zone_id = var.public_zone_id
  name    = "${var.name}.${var.domain_name}"
  type    = "A"

  count = var.include_public_dns_record == "yes" ? 1 : 0

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}
