locals {
  terraform_master_account_name = "master-account"
}

module "master_terraform" {
  source = "../terraform-modules/terraform-runner"

  terraform_directory                = "./terraform-main-account"
  terraform_project_workspace        = local.terraform_master_account_name
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
