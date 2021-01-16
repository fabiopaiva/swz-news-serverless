resource "aws_s3_bucket" "terraform_state" {
  bucket = format("%s-tf-state", var.organization)

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = format("%s-tf-state", var.organization)
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid       = "RequireEncryptedTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [format("arn:aws:s3:::%s/*", aws_s3_bucket.terraform_state.bucket)]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid       = "RequireEncryptedStorage"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = [format("arn:aws:s3:::%s/*", aws_s3_bucket.terraform_state.bucket)]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.terraform_state.json
}
