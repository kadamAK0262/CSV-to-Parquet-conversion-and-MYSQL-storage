output "s3_bucket_mapping_arn" {
  value = aws_s3_bucket.HTC_POC_USECASE_618580_BUCKET.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.HTC_POC_USECASE_618580_BUCKET.bucket
}

output "s3_csv_folder_name" {
  value = aws_s3_object.data_folder.key
}

output "s3_parquet_folder_name" {
  value = aws_s3_object.parquet_folder.key
}

output "glue_script_folder_name" {
  value = aws_s3_object.glue_script_folder.key
}