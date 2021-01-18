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



output "hosted_zone_ns" {
  value = aws_route53_zone.primary.name_servers
}
