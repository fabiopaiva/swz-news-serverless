locals {
  terraform_master_account_name = "master-account"
  terraform_master_role         = "TerraformMasterRole"
}

module "master_terraform" {
  source = "./modules/terraform-runner"

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
      value = aws_ssm_parameter.github_owner.value
      type  = "PLAINTEXT"
    },
    {
      name  = "github_repo"
      value = github_repository.swz_news.name
      type  = "PLAINTEXT"
    },
    {
      name  = "github_token"
      value = aws_ssm_parameter.github_token.name
      type  = "PARAMETER_STORE"
    },
    {
      name  = "aws_account_id"
      value = aws_ssm_parameter.aws_account_id.value
      type  = "PLAINTEXT"
    },
  ]

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "terraform_master_pipeline_attachment" {
  role = module.master_terraform.terraform_pipeline_role_id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
