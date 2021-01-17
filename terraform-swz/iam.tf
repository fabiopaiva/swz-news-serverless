data "aws_iam_policy_document" "serverless_deployment_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.pipeline_runner_aws_account_id]
    }
  }
}

resource "aws_iam_role" "serverless_deployment_role" {
  name               = "serverless-deployment-role"
  assume_role_policy = data.aws_iam_policy_document.serverless_deployment_role.json
}
