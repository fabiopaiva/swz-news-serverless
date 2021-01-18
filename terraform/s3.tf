resource "aws_s3_bucket" "upload_bucket" {
  bucket = format("uploads-%s", terraform.workspace)

  tags = local.tags
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = format("logs-%s", terraform.workspace)
  acl    = "log-delivery-write"
  tags   = local.tags

  lifecycle_rule {
    enabled = true

    expiration {
      days = 30
    }
  }
}


resource "aws_s3_bucket" "swz_news_website_bucket" {
  bucket = format("static-website-%s", terraform.workspace)

  website {
    index_document = "index.html"
  }

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/website"
  }

  tags = local.tags
}

resource "aws_s3_bucket" "pipeline_artifacts_bucket" {
  bucket = format("codepipeline-artifacts-%s", terraform.workspace)
  acl    = "private"

  lifecycle_rule {
    enabled = true

    expiration {
      days = 5
    }
  }

  tags = local.tags
}
