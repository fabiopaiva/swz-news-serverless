variable "organization" {
  default = "swz"
}

variable "github_token" {
  description = "Github token"
}

variable "github_owner" {
  description = "Github owner"
}

variable "repository_main_branch" {
  default = "master"
}

variable "aws_region" {
  default = "eu-central-1"
}

variable "admin_email_pattern" {
  default = "fabio+%s@paiva.info"
}

variable "aws_main_account_id" {
  default = "986315062044"
}
