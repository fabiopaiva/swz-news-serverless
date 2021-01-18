resource "aws_kms_key" "swz_key" {}

resource "aws_kms_alias" "swz_key" {
  name          = format("alias/swz-key-alias-%s", terraform.workspace)
  target_key_id = aws_kms_key.swz_key.key_id
}
