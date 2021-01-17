data "aws_iam_policy_document" "terraform_pipeline_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [
        "codebuild.amazonaws.com",
        "codepipeline.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "terraform_pipeline_role" {
  name = format("terraform-role-%s", var.terraform_project_workspace)

  assume_role_policy = data.aws_iam_policy_document.terraform_pipeline_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "terraform_pipeline_policy" {
  // Terraform state management configuration
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:ListBucket",
    ]
    resources = [
      var.terraform_state_bucket_arn,
      format("%s/*", var.terraform_state_bucket_arn)
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject*",
    ]
    resources = [
      format("%s/env:/%s/*", var.terraform_state_bucket_arn, var.terraform_project_workspace)
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [var.terraform_state_dynamodb_table_arn]
  }

  // Pipeline artifacts configuration

  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject*",
      "s3:ListBucket",
      "s3:PutObject*",
    ]
    resources = [
      format("%s/*", aws_s3_bucket.pipeline_bucket.arn),
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:ListObjects",
    ]
    resources = [
      aws_s3_bucket.pipeline_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      aws_codebuild_project.terraform_plan.arn,
      aws_codebuild_project.terraform_apply.arn
    ]
  }

  dynamic "statement" {
    for_each = compact([var.codestar_connection_arn])
    content {
      effect = "Allow"
      actions = [
        "codestar-connections:UseConnection"
      ]
      resources = [statement.value]
    }
  }

  statement {
    sid    = "AllowLogging"
    effect = "Allow"

    resources = ["*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid    = "AllowAccessToTheKMSKey"
    effect = "Allow"

    resources = [var.kms_alias_arn]

    actions = [
      "kms:DescribeKey",
      "kms:ListKeyPolicies",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]
  }
}

resource "aws_iam_role_policy" "terraform_pipeline_policy" {
  name = format("terraform-policy-%s", var.terraform_project_workspace)
  role = aws_iam_role.terraform_pipeline_role.id

  policy = data.aws_iam_policy_document.terraform_pipeline_policy.json
}
