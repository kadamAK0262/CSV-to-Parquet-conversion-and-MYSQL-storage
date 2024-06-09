data "aws_iam_policy_document" "HTC_POC_USECASE2_618580_ASSUME_ROLE" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com", "lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


