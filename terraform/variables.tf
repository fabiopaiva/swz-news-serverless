variable "organization" {
  default = "swz"
}

variable "aws_region" {
  default = "eu-central-1"
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

variable "repository_main_branch" {
  default = "master"
}

locals {
  environment = var.environments[terraform.workspace]
  tags = {
    Workspace   = terraform.workspace
    Project     = "swz-news"
    Environment = local.environment
  }
}
