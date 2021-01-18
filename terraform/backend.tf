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
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
}

