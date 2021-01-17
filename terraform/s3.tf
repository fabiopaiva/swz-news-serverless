resource "aws_s3_bucket" "upload_bucket" {
  bucket = format("%s-uploads", terraform.workspace)

  tags = local.tags
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = format("%s-logs", terraform.workspace)
  acl    = "log-delivery-write"
  tags   = local.tags
}


resource "aws_s3_bucket" "swz_news_website_buckets" {
  bucket = format("%s-static-website", terraform.workspace)

  website {
    index_document = "index.html"
  }

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/website"
  }

  tags = local.tags
}

resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = format("pipeline-artifacts-%s", terraform.workspace)
  acl    = "private"

  tags = local.tags
}
