resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = format("terraform-pipeline-artifacts-%s", var.terraform_project_workspace)
  acl    = "private"

  tags = var.tags
}
