resource "aws_iam_role" "HTC_POC_618580_LAMBDA_ROLE" {
  name = var.role_name
  assume_role_policy = var.assume_role
  
}
