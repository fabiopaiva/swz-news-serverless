variable "organization" {
  default = "swz"
}

variable "aws_region" {
  default = "eu-central-1"
}

variable "pipeline_runner_aws_account_id" {
  default = "461719735338"
}

variable "aws_account_id" {
  default = "930472115194"
}

variable "environments" {
  type = map(string)
  default = {
    "swz-news-prd" : "prd"
  }
}

variable "github_owner" {
  description = "Github owner"
}

variable "github_repo" {
  description = "Github repo"
}

variable "github_secret" {
  description = "Github secret"
}

variable "repository_main_branch" {
  default = "feature/frontend-app"
}

locals {
  environment = var.environments[terraform.workspace]
  tags = {
    Workspace   = terraform.workspace
    Project     = "swz-news"
    Environment = local.environment
  }
}
