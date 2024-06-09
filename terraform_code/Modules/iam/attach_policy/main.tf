resource "aws_iam_policy_attachment" "HTC_POC_OP_618580_POLICY_ATTACH" {
  name = var.policy_attachment
  roles = [var.role_name]
  policy_arn = var.policy_arn
}
