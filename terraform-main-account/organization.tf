locals {
  production_project_name = format("%s-news-production", var.organization)
}

resource "aws_organizations_account" "swz_news_production_account" {
  name      = local.production_project_name
  email     = format(var.admin_email_pattern, local.production_project_name)
  role_name = "OrganizationAccountAccessRole"

  lifecycle {
    ignore_changes = [role_name]
  }
}

output "swz_news_production_account_id" {
  value = aws_organizations_account.swz_news_production_account.id
}
