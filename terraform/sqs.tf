resource "aws_sqs_queue" "news_post_queue" {
  name                              = format("post-news-queue-%s", local.environment)
  kms_master_key_id                 = aws_kms_key.swz_key.id
  kms_data_key_reuse_period_seconds = 300

  tags = local.tags
}
