resource "aws_iam_policy" "HTC_POC_Usecase2_618580_POLICY" {
  name = var.policy_name
  description = var.policy_description
  policy = file("${path.module}/policies/policy.json")
}
