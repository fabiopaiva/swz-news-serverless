resource "aws_codepipeline" "terraform_pipeline" {
  name     = format("terraform-pipeline-%s", var.terraform_project_workspace)
  role_arn = aws_iam_role.terraform_pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = var.kms_alias_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        ConnectionArn    = var.source_action_configuration.ConnectionArn
        FullRepositoryId = var.source_action_configuration.FullRepositoryId
        BranchName       = var.source_action_configuration.BranchName
      }
      input_artifacts  = []
      name             = "Source"
      output_artifacts = ["SourceArtifact"]
      owner            = var.source_action_owner
      provider         = var.source_action_provider
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
        ProjectName = aws_codebuild_project.terraform_plan.name
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
        ProjectName = aws_codebuild_project.terraform_apply.name
      }
    }
  }

  tags = var.tags
}
