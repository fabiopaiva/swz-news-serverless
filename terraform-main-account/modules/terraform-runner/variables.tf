variable "tags" {
  type    = map(string)
  default = {}
}

variable "terraform_directory" {
  type        = string
  description = "The directory path for terraform configuration. Default is . "
  default     = "."
}

variable "terraform_project_workspace" {
  type        = string
  description = "Terraform project workspace"
}

variable "terraform_environment_variables" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  description = "Environemnt variables to pass to Terraform. No need adding the prefix TF_VAR"
  default     = []
}

variable "kms_arn" {
  type        = string
  description = "KMS ARN for S3 encryption"
}

variable "kms_alias_arn" {
  type        = string
  description = "KMS alias ARN for S3 encryption"
}

variable "source_action_configuration" {
  type = object({
    ConnectionArn    = string
    FullRepositoryId = string
    BranchName       = string
  })
  description = "Code pipeline source action configuration"
}

variable "source_action_owner" {
  type        = string
  description = "Code pipeline source action owner"
  default     = "AWS"
}

variable "source_action_provider" {
  type        = string
  description = "Source action provider"
  default     = "CodeStarSourceConnection"
}

variable "terraform_state_bucket_arn" {
  type        = string
  description = "Bucket ARN used to store Terraform state"
}

variable "terraform_state_dynamodb_table_arn" {
  type        = string
  description = "DynamoDB table ARN used to lock Terraform state"
}

variable "codestar_connection_arn" {
  type        = string
  description = "AWS CodeStar connection ARN. Default is null"
  default     = null
}
