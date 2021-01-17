resource "github_repository" "swz_news" {
  name        = "swz-news-serverless"
  description = "My awesome serverless news website running on AWS"

  visibility = "public"
}

resource "random_string" "github_secret" {
  length  = 99
  special = false
}

resource "github_repository_webhook" "swz_news_terraform_hook" {
  repository = github_repository.swz_news.name
  events     = ["push"]

  configuration {
    url          = aws_codepipeline_webhook.deployment_pipeline_webhook.url
    insecure_ssl = false
    content_type = "json"
    secret       = random_string.github_secret.result
  }
}

output "github_html_url" {
  value = github_repository.swz_news.html_url
}
