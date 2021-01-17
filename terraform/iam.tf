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
}

resource "aws_iam_role_policy" "terraform_pipeline_policy" {
  name   = format("%s-policy", local.codepipeline_website_name)
  role   = aws_iam_role.frontend_pipeline_role.id
  policy = data.aws_iam_policy_document.frontend_pipeline_policy.json
}
