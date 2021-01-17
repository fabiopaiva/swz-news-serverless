resource "aws_s3_bucket" "deployment_pipeline_bucket" {
  bucket = format("%s-deployment-artifacts", local.production_project_name)
  acl    = "private"
}
