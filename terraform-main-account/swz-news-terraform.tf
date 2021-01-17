locals {
  terraform_swz_news_prd_name = "swz-news-prd"
}

module "swz_news_terraform" {
  source = "../terraform-modules/terraform-runner"

  terraform_directory                = "./terraform"
  terraform_project_workspace        = local.terraform_swz_news_prd_name
  kms_arn                            = aws_kms_key.swz_key.arn
  kms_alias_arn                      = aws_kms_alias.swz_key.arn
  terraform_state_bucket_arn         = aws_s3_bucket.terraform_state.arn
  terraform_state_dynamodb_table_arn = aws_dynamodb_table.terraform_state_lock.arn
  codestar_connection_arn            = local.codestarconnection_arn

  source_action_configuration = {
    ConnectionArn    = local.codestarconnection_arn
    FullRepositoryId = format("%s/%s", var.github_owner, github_repository.swz_news.name)
    BranchName       = "master"
  }

  terraform_environment_variables = [
    {
      name  = "github_owner"
      value = var.github_owner
    },
    {
      name  = "github_repo"
      value = github_repository.swz_news.name
    }
  ]

  tags = local.tags
}

//data "aws_iam_policy_document" "terraform_cross_account_pipeline_role" {
//  statement {
//    effect  = "Allow"
//    actions = ["sts:AssumeRole"]
//    principals {
//      type        = "AWS"
//      identifiers = [format("arn:aws:iam::%s:root", aws_organizations_account.swz_news_production_account.id)]
//    }
//  }
//}

data "aws_iam_policy_document" "terraform_cross_account_pipeline_policy" {
  // Permissions to change child account
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [format("arn:aws:iam::%s:role/OrganizationAccountAccessRole", aws_organizations_account.swz_news_production_account.id)]
  }
}

resource "aws_iam_role_policy" "terraform_pipeline_policy" {
  name = format("terraform-cross-account-policy-%s", local.terraform_swz_news_prd_name)
  role = module.swz_news_terraform.terraform_pipeline_role_id

  policy = data.aws_iam_policy_document.terraform_cross_account_pipeline_policy.json
}
