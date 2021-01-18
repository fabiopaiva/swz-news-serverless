data "aws_iam_policy_document" "frontend_pipeline_role" {
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

resource "aws_iam_role" "frontend_pipeline_role" {
  name = format("%s-frontend-role", local.codepipeline_website_name)

  assume_role_policy = data.aws_iam_policy_document.frontend_pipeline_role.json

  tags = local.tags
}


data "aws_iam_policy_document" "frontend_pipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      aws_codebuild_project.frontend_build.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = [aws_codestarconnections_connection.github_pipeline_connection.arn]
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

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject*",
    ]
    resources = [
      format("%s/*", aws_s3_bucket.swz_news_website_buckets.arn),
    ]
  }
}

resource "aws_iam_role_policy" "frontend_pipeline_policy" {
  name   = format("%s-policy", local.codepipeline_website_name)
  role   = aws_iam_role.frontend_pipeline_role.id
  policy = data.aws_iam_policy_document.frontend_pipeline_policy.json
}
