##############################################
# S3-Bucket Creation
##############################################
 
locals {
  csv_content = file("${path.module}/data-file/customer.csv")
  md5_hash    = md5(local.csv_content)
}
 
resource "aws_s3_bucket" "HTC_POC_USECASE_618580_BUCKET" {
  bucket = var.HTC_POC_USECASE_618580_BUCKET_NAME
  tags = var.common_tags
  
}

resource "aws_s3_object" "data_folder" {
  bucket = aws_s3_bucket.HTC_POC_USECASE_618580_BUCKET.bucket
  key    = var.HTC_POC_USECASE_618580_BUCKET_KEY_FOLDER  # Create 'data' folder inside the bucket
  # source = "${path.module}/data-file/customer.csv"
 
  # metadata = {
  #   md5 = local.md5_hash
  # }
  # acl    = "public"  # Set ACL as per your requirements
}

resource "local_file" "md5_output" {
  content  = "md5_hash = \"${local.md5_hash}\""
  filename = "${path.module}/data-file/md5_output.txt"
}


resource "aws_s3_object" "parquet_folder" {
  bucket = aws_s3_bucket.HTC_POC_USECASE_618580_BUCKET.bucket
  key    = var.HTC_POC_USECASE_618580_BUCKET_PARQUET_FOLDER  # Create 'data' folder inside the bucket
 
}

resource "aws_s3_object" "glue_script_folder" {
  bucket = aws_s3_bucket.HTC_POC_USECASE_618580_BUCKET.bucket
  key  = "glue-scripts/glue_script.py"
  source = "${path.module}/glue-script/glue_script.py"
}


resource "aws_s3_bucket_notification" "example_s3_notification" {
  bucket = aws_s3_bucket.HTC_POC_USECASE_618580_BUCKET.id
  # bucket = aws_s3_bucket.HTC_POC_USECASE_618580_BUCKET.bucket

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*" , "s3:ObjectRemoved:*"]
    filter_prefix       = "data/"  # Specify the folder you want to monitor
  }
}

resource "aws_lambda_permission" "s3_trigger_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.HTC_POC_USECASE2_618580_LambdaFunction_FunctionName
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_mapping_arn
}





# resource "aws_s3_bucket" "example_bucket" {
#   bucket = "your-unique-bucket-name"
#   acl    = "private"
# }

# resource "aws_s3_bucket_object" "example_object" {
#   bucket = aws_s3_bucket.example_bucket.bucket
#   key    = "your-folder-name/"
#   acl    = "private"
# }