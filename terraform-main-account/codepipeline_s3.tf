resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = format("%s-pipeline-artifacts", local.production_project_name)
  acl    = "private"
}
