locals {
  terraform_swz_news_prd_name = "swz-news-prd"
}

module "swz_news_terraform" {
  source = "modules/terraform-runner"

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
      type  = "PLAINTEXT"
    },
    {
      name  = "github_repo"
      value = github_repository.swz_news.name
      type  = "PLAINTEXT"
    }
  ]

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "terraform_swz_news_pipeline_attachment" {
  role = module.swz_news_terraform.terraform_pipeline_role_id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
