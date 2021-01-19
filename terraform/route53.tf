resource "aws_route53_zone" "primary" {
  name = var.domain_name
  tags = local.tags
}

resource "aws_route53_record" "cert_validation" {
  name    = tolist(aws_acm_certificate.cloudfront_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cloudfront_cert.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.cloudfront_cert.domain_validation_options)[0].resource_record_value]
  ttl     = 300
  zone_id = aws_route53_zone.primary.zone_id

  depends_on = [aws_route53_zone.primary]
}

resource "aws_route53_record" "news_cloudfront_cname" {
  name    = local.news_domain
  type    = "CNAME"
  records = [aws_cloudfront_distribution.news_website.domain_name]
  ttl     = 300
  zone_id = aws_route53_zone.primary.zone_id

  depends_on = [aws_route53_zone.primary]
}

// cognito requires root domain
resource "aws_route53_record" "root_domain" {
  name    = var.domain_name
  type    = "A"
  records = ["127.0.0.1"]
  ttl     = 300
  zone_id = aws_route53_zone.primary.zone_id

  depends_on = [aws_route53_zone.primary]
}

resource "aws_route53_record" "swz_auth_pool_domain_record" {
  name    = aws_cognito_user_pool_domain.swz_auth_pool_domain.domain
  type    = "A"
  zone_id = aws_route53_zone.primary.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.swz_auth_pool_domain.cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }
  depends_on = [aws_route53_record.root_domain]
}


output "hosted_zone_ns" {
  value = aws_route53_zone.primary.name_servers
}
