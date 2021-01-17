terraform {
  backend "s3" {
    bucket         = "swz-tf-state"
    key            = "terraform.tfstate"
    dynamodb_table = "swz-tf-state"
    region         = "eu-central-1"
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = format("arn:aws:iam::%s:role/OrganizationAccountAccessRole", var.aws_account_id)
  }
}
