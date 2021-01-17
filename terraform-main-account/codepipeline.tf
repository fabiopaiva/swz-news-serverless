locals {
  codepipeline_name = format("%s-deployment-pipeline", local.production_project_name)
}

resource "aws_codepipeline" "deployment_pipeline" {
  name     = local.codepipeline_name
  role_arn = aws_iam_role.deployment_pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.deployment_pipeline_bucket.bucket
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
        OAuthToken           = var.github_token
        Branch               = var.repository_main_branch
        Owner                = var.github_owner
        PollForSourceChanges = "false"
        Repo                 = github_repository.swz_news.name
      }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "ThirdParty"
      provider  = "GitHub"
      run_order = 1
      version   = "1"
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
        ProjectName = local.codepipeline_name
      }
    }
  }
}

resource "aws_codepipeline_webhook" "deployment_pipeline_webhook" {
  authentication  = "GITHUB_HMAC"
  name            = format("%s-webhook", local.codepipeline_name)
  target_action   = "Source"
  target_pipeline = aws_codepipeline.deployment_pipeline.name

  authentication_configuration {
    secret_token = random_string.github_secret.result
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}
