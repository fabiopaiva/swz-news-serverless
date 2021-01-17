resource "aws_codebuild_project" "terraform_plan" {
  badge_enabled  = false
  build_timeout  = 60
  name           = format("terraform-plan-%s", var.terraform_project_workspace)
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
      name  = "TERRAFORM_WORKSPACE"
      value = var.terraform_project_workspace
    }

    dynamic "environment_variable" {
      for_each = var.terraform_environment_variables
      content {
        name  = format("TF_VAR_%s", environment_variable.value["name"])
        value = environment_variable.value["value"]
        type  = lookup(environment_variable.value, "type", "PLAINTEXT")
      }
    }

    dynamic "environment_variable" {
      for_each = compact([var.terraform_directory])
      content {
        name  = "TERRAFORM_DIRECTORY"
        value = environment_variable.value
      }
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
    buildspec = "terraform-modules/terraform-runner/tf-plan-buildspec.yml"
  }

  tags = var.tags
}

resource "aws_codebuild_project" "terraform_apply" {
  badge_enabled  = false
  build_timeout  = 60
  name           = format("terraform-apply-%s", var.terraform_project_workspace)
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

    dynamic "environment_variable" {
      for_each = var.terraform_environment_variables
      content {
        name  = format("TF_VAR_%s", environment_variable.value["name"])
        value = environment_variable.value["value"]
        type  = lookup(environment_variable.value, "type", "PLAINTEXT")
      }
    }

    dynamic "environment_variable" {
      for_each = compact([var.terraform_directory])
      content {
        name  = "TERRAFORM_DIRECTORY"
        value = environment_variable.value
      }
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
    buildspec = "terraform-modules/terraform-runner/tf-apply-buildspec.yml"
  }

  tags = var.tags
}
