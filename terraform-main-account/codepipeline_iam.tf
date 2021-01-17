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

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [format("arn:aws:iam::%s:root", aws_organizations_account.swz_news_production_account.id)]
    }
  }
}

resource "aws_iam_role" "terraform_pipeline_role" {
  name = format("%s-terraform-role", local.codepipeline_name)

  assume_role_policy = data.aws_iam_policy_document.terraform_pipeline_role.json
}

data "aws_iam_policy_document" "terraform_pipeline_policy" {
  // Permissions to change child account
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [format("arn:aws:iam::%s:role/OrganizationAccountAccessRole", aws_organizations_account.swz_news_production_account.id)]
  }
  // Grant permission to swz-nes-prd workspace
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.terraform_state.arn,
      format("%s/*", aws_s3_bucket.terraform_state.arn)
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject*",
    ]
    resources = [
      format("%s/env:/swz-news-prd/*", aws_s3_bucket.terraform_state.arn)
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [aws_dynamodb_table.terraform_state_lock.arn]
  }

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
      aws_codebuild_project.swz_news_terraform_plan.arn,
      aws_codebuild_project.swz_news_terraform_apply.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = [aws_codestarconnections_connection.swz_news_pipeline_connection.arn]
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

    resources = [
      aws_kms_key.swz_key.arn,
    ]

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
  name = format("%s-policy", local.codepipeline_name)
  role = aws_iam_role.terraform_pipeline_role.id

  policy = data.aws_iam_policy_document.terraform_pipeline_policy.json
}
