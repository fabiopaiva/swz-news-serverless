resource "aws_codebuild_project" "swz_news_terraform_plan" {
  badge_enabled  = false
  build_timeout  = 60
  name           = format("%s-terraform-plan", local.production_project_name)
  queued_timeout = 480
  service_role   = aws_iam_role.terraform_pipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.pipeline_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.13.6"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
    environment_variable {
      name = "TERRAFORM_WORKSPACE"
      value = "swz-news-prd"
    }
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
    type      = "CODEPIPELINE"
    buildspec = "terraform-main-account/tf-plan-buildspec.yml"
  }
}

resource "aws_codebuild_project" "swz_news_terraform_apply" {
  badge_enabled  = false
  build_timeout  = 60
  name           = format("%s-terraform-apply", local.production_project_name)
  queued_timeout = 480
  service_role   = aws_iam_role.terraform_pipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.pipeline_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.13.6"
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
    type      = "CODEPIPELINE"
    buildspec = "terraform-main-account/tf-apply-buildspec.yml"
  }
}
