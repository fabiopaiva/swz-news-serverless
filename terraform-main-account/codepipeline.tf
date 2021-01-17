locals {
  codepipeline_name = format("%s-pipeline", local.production_project_name)
}

resource "aws_codepipeline" "terraform_swz_news_pipeline" {
  name     = format("terraform-%s", local.codepipeline_name)
  role_arn = aws_iam_role.terraform_pipeline_role.arn

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
        ConnectionArn    = aws_codestarconnections_connection.swz_news_pipeline_connection.arn
        FullRepositoryId = format("%s/%s", var.github_owner, github_repository.swz_news.name)
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
    name = "TerraformPlan"

    action {
      name             = "Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.swz_news_terraform_plan.name
      }
    }
  }

  stage {
    name = "TerraformApply"

    action {
      name      = "Confirm"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 1
    }

    action {
      name             = "Apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["BuildArtifact"]
      output_artifacts = []
      version          = "1"
      run_order        = 2

      configuration = {
        ProjectName = aws_codebuild_project.swz_news_terraform_apply.name
      }
    }
  }
}

resource "aws_codestarconnections_connection" "swz_news_pipeline_connection" {
  name          = format("%s-prd-connection", var.organization)
  provider_type = "GitHub"
}
