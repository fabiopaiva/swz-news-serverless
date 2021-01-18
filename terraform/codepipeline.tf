locals {
  codepipeline_application_name = format("application-pipeline-%s", local.environment)
}

resource "aws_codepipeline" "application_pipeline" {
  name     = format("application-%s", local.codepipeline_application_name)
  role_arn = aws_iam_role.application_pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_alias.swz_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github_pipeline_connection.arn
        FullRepositoryId = format("%s/%s", var.github_owner, var.github_repo)
        BranchName       = var.repository_main_branch
      }
      input_artifacts  = []
      name             = "Source"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildFrontend"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifactFrontend"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.frontend_build.name
      }
    }

    action {
      name             = "BuildBackend"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifactBackend"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.backend_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "BucketName" = aws_s3_bucket.swz_news_website_bucket.bucket
        "Extract"    = "true"
      }
      input_artifacts = [
        "BuildArtifactFrontend",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "S3"
      run_order        = 1
      version          = "1"
    }
  }
}

resource "aws_codestarconnections_connection" "github_pipeline_connection" {
  name          = format("github-connection-%s", local.environment)
  provider_type = "GitHub"
}
