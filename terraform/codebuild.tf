resource "aws_codebuild_project" "frontend_build" {
  badge_enabled  = false
  build_timeout  = 60
  name           = format("frontend-build-%s", local.environment)
  queued_timeout = 480
  service_role   = aws_iam_role.application_pipeline_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.pipeline_artifacts_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "node:14-alpine"
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
    buildspec = "frontend/buildspec.yml"
  }
}


resource "aws_codebuild_project" "backend_build" {
  badge_enabled  = false
  build_timeout  = 60
  name           = format("backend-build-%s", local.environment)
  queued_timeout = 480
  service_role   = aws_iam_role.backend_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.pipeline_artifacts_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "nikolaik/python-nodejs:python3.6-nodejs14-alpine"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
    environment_variable {
      name = "DEPLOYMENT_BUCKET"
      value = aws_s3_bucket.pipeline_artifacts_bucket.bucket
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
    buildspec = "backend/buildspec.yml"
  }
}
