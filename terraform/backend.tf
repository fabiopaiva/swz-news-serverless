terraform {
  backend "s3" {
    bucket         = "swz-tf-state"
    key            = "terraform.tfstate"
    dynamodb_table = "swz-tf-state"
    region         = "eu-central-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  // Unfortunately it was not possible to use cross account configuration due to a limit on CodeBuild set to 0 on new accounts
//  assume_role {
//    role_arn = format("arn:aws:iam::%s:role/OrganizationAccountAccessRole", var.aws_account_id)
//  }
}
