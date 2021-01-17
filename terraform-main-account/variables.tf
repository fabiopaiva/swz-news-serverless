variable "organization" {
  default = "swz"
}

variable "github_token" {
  description = "Github token"
}

variable "github_owner" {
  description = "Github owner"
}

variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_account_id" {
  description = "AWS master account id"
}

variable "admin_email_pattern" {
  default = "fabio+%s@paiva.info"
}

locals {
  tags = {
    Workspace = terraform.workspace
    Project   = "swz"
  }
}
