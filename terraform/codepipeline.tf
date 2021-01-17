locals {
  codepipeline_website_name = format("frontend-pipeline-%s", local.environment)
}

resource "aws_codepipeline" "frontend_pipeline" {
  name     = format("frontend-%s", local.codepipeline_website_name)
  role_arn = aws_iam_role.frontend_pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
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
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.frontend_build.name
      }
    }
  }
}

resource "aws_codestarconnections_connection" "github_pipeline_connection" {
  name          = format("github-connection-%s", local.environment)
  provider_type = "GitHub"
}
