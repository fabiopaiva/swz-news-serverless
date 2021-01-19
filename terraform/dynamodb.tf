resource "aws_dynamodb_table" "swz_news_table" {
  name = "SwzNewsTable"
  // PAY_PER_REQUEST will provide high scalability but it's not needed here
  // This data will be consumed through CloudFront with a cache layer and will be persisted by SQS.
  // billing_mode   = "PAY_PER_REQUEST"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "slug"
  range_key      = "date"

  attribute {
    name = "slug"
    type = "S"
  }

  attribute {
    name = "date"
    type = "S"
  }

  tags = local.tags
}
