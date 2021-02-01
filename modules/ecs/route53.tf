resource "aws_route53_record" "service_public" {
  zone_id = var.public_zone_id
  name    = "${local.common_tags["Environment"]}-${local.common_tags["Project"]}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}
