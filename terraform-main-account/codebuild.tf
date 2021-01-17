resource "aws_codebuild_project" "swz_news_terraform_plan" {
  badge_enabled  = false
  build_timeout  = 60
  name           = format("%s-terraform-plan", local.production_project_name)
  queued_timeout = 480
  service_role   = aws_iam_role.swz_news_pipeline_role.arn

  artifacts {
    encryption_disabled    = false
    name                   = "terraform-plan"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}
