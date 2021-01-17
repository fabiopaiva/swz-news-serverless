provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = format("arn:aws:iam::%s:role/TerraformMaster", var.aws_account_id)
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
