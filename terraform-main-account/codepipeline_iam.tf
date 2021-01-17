data "aws_iam_policy_document" "deployment_pipeline_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["codepipeline.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "deployment_pipeline_role" {
  name = format("%s-role", local.codepipeline_name)

  assume_role_policy = data.aws_iam_policy_document.deployment_pipeline_role.json
}

data "aws_iam_policy_document" "deployment_pipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.deployment_pipeline_bucket.arn,
      format("%s/*", aws_s3_bucket.deployment_pipeline_bucket.arn)
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    // TODO: specify resource
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "deployment_pipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.deployment_pipeline_role.id

  policy = data.aws_iam_policy_document.deployment_pipeline_policy.json
}
