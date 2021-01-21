resource "aws_dynamodb_table" "swz_news_table" {
  name = "SwzNewsTable"
  // PAY_PER_REQUEST will provide high scalability but it's not needed here
  // This data will be consumed through CloudFront with a cache layer and will be persisted by SQS.
  // billing_mode   = "PAY_PER_REQUEST"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = local.tags
}
