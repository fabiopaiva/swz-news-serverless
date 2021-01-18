data "aws_iam_policy_document" "application_pipeline_role" {
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

data "aws_iam_policy_document" "application_pipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      aws_codebuild_project.frontend_build.arn,
      aws_codebuild_project.backend_build.arn,
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
    sid       = "AllowLogging"
    effect    = "Allow"
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
      format("%s/*", aws_s3_bucket.pipeline_artifacts_bucket.arn),
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
      aws_s3_bucket.pipeline_artifacts_bucket.arn,
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
      format("%s/*", aws_s3_bucket.swz_news_website_bucket.arn),
    ]
  }
}

// application pipelines
resource "aws_iam_role" "application_pipeline_role" {
  name               = format("%s-application-pipeline-role", local.codepipeline_application_name)
  assume_role_policy = data.aws_iam_policy_document.application_pipeline_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy" "application_pipeline_policy" {
  name   = format("%s-policy", local.codepipeline_application_name)
  role   = aws_iam_role.application_pipeline_role.id
  policy = data.aws_iam_policy_document.application_pipeline_policy.json
}


resource "aws_iam_role" "backend_codebuild_role" {
  name               = format("%s-backend-codebuild-role", local.codepipeline_application_name)
  assume_role_policy = data.aws_iam_policy_document.application_pipeline_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy" "backend_codebuild_general_policy" {
  name   = format("backend-%s-general-policy", local.codepipeline_application_name)
  role   = aws_iam_role.backend_codebuild_role.id
  policy = data.aws_iam_policy_document.application_pipeline_policy.json
}

data "aws_iam_policy_document" "backend_serverless_policy" {
  // TODO: Create specific rules for Serverless
//  statement {
//    effect  = "Allow"
//    actions = ["cloudformation:*"]
//    resources = [
//      format(
//        "arn:aws:cloudformation:%s:%s:stack/swz-news-backend-%s/*",
//        data.aws_region.current.name,
//        data.aws_caller_identity.current.account_id,
//        local.environment
//      )
//    ]
//  }

  statement {
    effect = "Allow"
    actions = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "backend_codebuild_serverless_policy" {
  name   = format("backend-%s-serverless-policy", local.codepipeline_application_name)
  role   = aws_iam_role.backend_codebuild_role.id
  policy = data.aws_iam_policy_document.backend_serverless_policy.json
}
