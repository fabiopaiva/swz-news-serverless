resource "github_repository" "swz_news" {
  name        = "swz-news-serverless"
  description = "My awesome serverless news website running on AWS"

  visibility = "private"
}

output "github_html_url" {
  value = github_repository.swz_news.html_url
}
