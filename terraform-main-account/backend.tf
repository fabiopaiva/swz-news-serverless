terraform {
    backend "s3" {
      bucket         = "swz-tf-state"
      key            = "terraform.tfstate"
      dynamodb_table = "swz-tf-state"
      region         = "eu-central-1"
      encrypt        = true
    }
}
