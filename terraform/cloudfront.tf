locals {
  news_website_origin_id = format("%s-id", aws_s3_bucket.swz_news_website_buckets.bucket)
}

resource "aws_cloudfront_distribution" "news_website" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.swz_news_website_buckets.bucket_regional_domain_name
    origin_id   = local.news_website_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
    error_caching_min_ttl = 3600
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.news_website_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 3600
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["NL"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.tags
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = local.news_website_origin_id
}

data "aws_iam_policy_document" "news_website_bucket_policy" {
  statement {
    sid    = "Cloudfront Origin Access list bucket"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
    actions   = ["S3:List*"]
    resources = [aws_s3_bucket.swz_news_website_buckets.arn]
  }
  statement {
    sid    = "Cloudfront Origin Access read content"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
    actions = [
      "S3:GetObject"
    ]
    resources = [format("%s/*", aws_s3_bucket.swz_news_website_buckets.arn)]
  }
}

resource "aws_s3_bucket_policy" "news_website_bucket_policy" {
  bucket = aws_s3_bucket.swz_news_website_buckets.bucket
  policy = data.aws_iam_policy_document.news_website_bucket_policy.json
}
