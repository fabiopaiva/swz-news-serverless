resource "aws_ssm_parameter" "github_token" {
  name  = "/tf-master/github/token"
  type  = "SecureString"
  value = var.github_token

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "github_owner" {
  name  = "/tf-master/github/owner"
  type  = "String"
  value = var.github_owner

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "aws_account_id" {
  name  = "/tf-master/aws/account_id"
  type  = "String"
  value = var.aws_account_id

  lifecycle {
    ignore_changes = [value]
  }
}
