resource "aws_acm_certificate" "cloudfront_cert" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [format("*.%s", var.domain_name)]
  tags                      = local.tags

  lifecycle {
    create_before_destroy = true
  }
}
