resource "aws_s3_bucket" "upload_bucket" {
  bucket = format("%s-uploads", terraform.workspace)
}
