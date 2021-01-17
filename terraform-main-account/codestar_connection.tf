locals {
  codestarconnection_arn = aws_codestarconnections_connection.github_connection.arn
}

resource "aws_codestarconnections_connection" "github_connection" {
  name          = "swz-news-connection"
  provider_type = "GitHub"
}
