//data "aws_iam_policy_document" "terraform_cross_acount_role" {
//  statement {
//    actions = [
//      "sts:AssumeRole",
//    ]
//
//    principals {
//      type        = "AWS"
//      identifiers = [format("arn:aws:iam::%s:root", aws_organizations_account.swz_news_production_account.id)]
//    }
//
//    effect = "Allow"
//  }
//}
//
//resource "aws_iam_role" "terraform_cross_acount_role" {
//  name = local.terraform_cross_account_role_name
//  assume_role_policy = data.aws_iam_policy_document.terraform_cross_acount_role.json
//}
//
//resource "aws_iam_role_policy_attachment" "terraform_cross_acount_role_attachment" {
//  role       = aws_iam_role.terraform_cross_acount_role.name
//  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
//}
