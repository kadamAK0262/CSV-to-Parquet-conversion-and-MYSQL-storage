data "archive_file" "HTC_POC_USECASE2_618580_Archive" {
  type        = "zip"
  source_file = var.HTC_POC_USECASE2_618580__FileName
  output_path = "${path.module}${var.HTC_POC_USECASE2_618580_Archive}"
}

# LAMBDA_FUNCTION_CRUD CREATION


resource "aws_lambda_function" "HTC_POC_OP_618580_LambdaFunction_Usecase2" {
  filename      = var.HTC_POC_USECASE2_618580_LambdaFunction_FileName_archives
  function_name = var.HTC_POC_USECASE2_618580_LambdaFunction_FunctionName
  role          = var.iam_role_arn
  handler       = var.HTC_POC_USECASE2_618580_LambdaFunction_Handler
  runtime       = var.HTC_POC_USECASE2_618580_LambdaFunction_Runtime
  timeout       = 15
  # layers        = ["arn:aws:lambda:ap-south-1:336392948345:layer:AWSSDKPandas-Python312:3"]  # ARN for AWS-provided pandas layer

  environment {
    variables = {
      S3_BUCKET       = var.HTC_POC_USECASE_618580_BUCKET_NAME
      SNS_TOPIC       = var.sns_arn
      GLUE_JOB_NAME   = var.HTC_POC_618580_USECASE_2_GLUE_NAME

    }
  }
  
  tags = var.common_tags
  
}
  
  # Add the S3 event trigger
  # event_source {
  #   s3 {
  #     bucket = aws_s3_bucket.example_bucket.bucket
  #     events = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]  # You can adjust the events based on your requirement
  #     filter_prefix = "your-folder-name/"  # Specify the folder you want to monitor
  #   }
  # }






# resource "aws_lambda_permission" "s3_trigger_permission" {
#   statement_id  = "AllowS3Invoke"
#   action        = "lambda:InvokeFunction"
#   function_name = var.HTC_POC_USECASE2_618580_LambdaFunction_FunctionName
#   principal     = "s3.amazonaws.com"
#   source_arn    = var.s3_bucket_mapping
# }





# resource "aws_lambda_event_source_mapping" "s3_mapping" {
#   event_source_arn = var.s3_bucket_mapping
#   function_name    = var.HTC_POC_USECASE2_618580_LambdaFunction_FunctionName
#   enabled          = true
#   batch_size       = 10  # Adjust this value based on your requirements
# }

