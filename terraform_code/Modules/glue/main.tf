resource "aws_glue_job" "HTC_POC_618580_USECASE_2_GLUE_JOB" {
  name          = var.HTC_POC_618580_USECASE_2_GLUE_NAME
  role_arn          = var.iam_role_arn
  
  command       {
    name = var.HTC_POC_USECASE_618579_GlueJob_Command_Name
    script_location = "s3://${var.s3_bucket_name}/${var.glue_script_folder_name}"
    python_version = "3"
    
  }
  default_arguments = {
    "--FILE_KEY"      = "s3://${var.s3_bucket_name}/${var.s3_csv_folder_name}"
    "--S3_PARQUET_PATH"  = "s3://${var.s3_bucket_name}/${var.s3_parquet_folder_name}"
    "--EC2_PUBLIC_IP"    = var.ec2_public_ip
    "JOB_NAME"           = var.HTC_POC_618580_USECASE_2_GLUE_NAME
    "--SNS_ARN"            = var.sns_arn
    "--S3_BUCKET_NAME"     = var.s3_bucket_name

    # Add the bookmark-related arguments
    # "--job-bookmark-option" = "job-bookmark-enable"
    # "--job-bookmark-name"   = "your_bookmark_name"
    # "--job-bookmark-disable-when-suspended" = "true"
    
  }

  execution_property {
    max_concurrent_runs = 1
  }

  # Set up bookmarks in the job
  # bookmarks = {
  #   job_bookmark_option                   = "job-bookmark-enable"
  #   job_bookmark_name                     = "your_bookmark_name"
  #   job_bookmark_disable_when_suspended   = true
  # }

  timeout = 10
  glue_version = "4.0"

  
  
}


# Define Glue script
# resource "aws_glue_script" "HTC_POC_USECASE2_618580_GLUE_SCRIPT" {
#   name = var.HTC_POC_618580_USECASE_2_GLUE_SCRIPT_NAME
#   language = var.HTC_POC_618580_USECASE_2_GLUE_SCRIPT_LANGUAGE
  
#   script {
#     # Glue script content goes here...
#     # Use the EC2 public IP dynamically in your MySQL connection parameters
#     inline_script = <<-EOT

#       import sys
#       import os
#       import hashlib
#       from awsglue.transforms import *
#       from awsglue.utils import getResolvedOptions
#       from pyspark.context import SparkContext
#       from awsglue.context import GlueContext
#       from awsglue.job import Job
#       from awsglue.dynamicframe import DynamicFrame
#       from pyspark.sql.functions import *
#       import boto3
 
#       # Get job arguments
#       args = getResolvedOptions(sys.argv, ['JOB_NAME', 'FILE_KEY', 'SNS_ARN', 'S3_BUCKET_NAME', 'S3_PARQUET_PATH', 'EC2_PUBLIC_IP'])
 
#       # Specify your S3 bucket
#       s3_bucket = args['S3_BUCKET_NAME']
 
#       # Initialize Spark and Glue contexts
#       sc = SparkContext()
#       glueContext = GlueContext(sc)
#       spark = glueContext.spark_session
#       job = Job(glueContext)
#       job.init(args['JOB_NAME'], args)
 
#       # SNS Configuration
#       sns_client = boto3.client('sns')
#       sns_topic_arn = args['SNS_ARN']  # Replace with your SNS topic ARN
 
#       # Function to notify SNS
#       def notify_sns(message):
#           if sns_topic_arn:
#               sns_client.publish(TopicArn=sns_topic_arn, Message=message, Subject="S3 Data Integrity Check")
#           else:
#               print(f"SNS topic ARN not provided. Unable to send notification. Message: {message}")
 
#       # Function to move file to folder
#       def move_file_to_folder(file_key, folder):
#           s3_client = boto3.client('s3')
#           s3_client.copy_object(Bucket=s3_bucket, CopySource=f"{s3_bucket}/{file_key}", Key=f"{folder}{os.path.basename(file_key)}")
 
#       # Function to convert CSV to Parquet
#       def convert_csv_to_parquet(file_key):
#           # Convert CSV to Parquet logic here
#           # For example, read CSV into DataFrame and write it to Parquet
#           df = spark.read.option("header", "true").csv(f"s3://{s3_bucket}/{file_key}")
 
#           # Write DataFrame to Parquet
#           parquet_output_path = f"{args['S3_PARQUET_PATH']}/{os.path.splitext(os.path.basename(file_key))[0]}.parquet"
#           df.write.parquet(parquet_output_path, mode="overwrite", compression="snappy")
#           print(f"Converted and uploaded {file_key} to {parquet_output_path}")
 
#       # Function to compute MD5 checksum
#       def compute_md5(buffer, s3_client):
#           md5 = hashlib.md5()
#           md5.update(buffer)
#           return md5.hexdigest()
 
#       # Process CSV file
#       def process_csv_file(file_key):
#           try:
#               print(f"Processing CSV file: {file_key}")
 
#               # Fetch ETag (MD5 hash) value from the file
#               s3_client = boto3.client('s3')
#               etag = s3_client.head_object(Bucket=s3_bucket, Key=file_key)['ETag'].strip('"')
 
#               # Calculate MD5 hash value from the content
#               response = s3_client.get_object(Bucket=s3_bucket, Key=file_key)
#               content_md5_hash = compute_md5(response['Body'].read(), s3_client)
 
#               # Compare ETag (MD5 hash) with calculated MD5 hash
#               if etag.lower() == content_md5_hash.lower():
#                   print(f"MD5 hashes match for file: {file_key}")
#                   # Notify through SNS
#                   notify_sns(f"New CSV file detected: {file_key}")
 
#                   # Move the file to the 'processed' folder
#                   move_file_to_folder(file_key, 'processed/')
 
#                   # Convert CSV to Parquet
#                   convert_csv_to_parquet(file_key)
 
#                   # Load the Parquet file into MySQL (Placeholder, adapt based on your MySQL configuration)
#                   # Define MySQL connection parameters
#                   mysql_url = "jdbc:mysql://{args['EC2_PUBLIC_IP']}:3306/customer_db"
#                   mysql_properties = {
#                       "user": "root",
#                       "password": "Admin#123",
#                       "driver": "com.mysql.cj.jdbc.Driver",
#                   }
#                   mysql_table_name = "customer_table"
 
#                   try:
#                       # Read Parquet file into DataFrame
#                       parquet_output_path = f"{args['S3_PARQUET_PATH']}/{os.path.splitext(os.path.basename(file_key))[0]}.parquet"
#                       parquet_df = spark.read.parquet(parquet_output_path)
 
#                       # Write DataFrame to MySQL
#                       parquet_df.write.mode("overwrite").jdbc(url=mysql_url, table=mysql_table_name, properties=mysql_properties)
#                       print("Data loaded into MySQL successfully.")
#                   except Exception as e:
#                       print(f"Error writing to MySQL: {str(e)}")
#                       # Optionally, you can log or handle the error here
 
#               else:
#                   print(f"MD5 hashes do not match for file: {file_key}")
#                   # Notify SNS about the error
#                   notify_sns(f"Error: Data corrupted or lost for file: {file_key}")
#                   # Move the file to the 'unmatched' folder
#                   move_file_to_folder(file_key, 'unmatched/')
 
#           except Exception as e:
#               print(f"Error processing CSV file: {str(e)}")
#               # Notify SNS about the error
#               notify_sns(f"Error processing CSV file: {str(e)}")
 
#       # Extract FILE_KEY from job arguments
#       file_key = args['FILE_KEY']
 
#       # Call the process_csv_file function
#       process_csv_file(file_key)
 
#       # Commit the job
#       job.commit()

#     EOT
#   }
# }






# Define Glue job
# resource "aws_glue_job" "glue_job" {
#   name          = "your_glue_job_name"
#   role          = var.iam_role_arn
#   command       = "pythonScript"
#   script_name   = aws_glue_script.glue_script.name
#   timeout       = 60
#   max_capacity  = 2

#   default_arguments = {
#     "--S3_CSV_PATH"      = "s3://your-csv-bucket/your-csv-folder/"
#     "--S3_PARQUET_PATH"  = "s3://your-parquet-bucket/your-parquet-folder/"
#     "--EC2_PUBLIC_IP"    = aws_instance.example_instance.public_ip
#     "JOB_NAME"           = "your_glue_job_name"
#   }
# }


# resource "aws_glue_job" "glue_job" {
#   name          = "your_glue_job_name"
#   role_arn          = aws_iam_role.glue_role.arn
#   command       = "python_script"
#   default_arguments = {
#     "--S3_CSV_PATH"      = "s3://your-csv-bucket/your-csv-folder/"
#     "--S3_PARQUET_PATH"  = "s3://your-parquet-bucket/your-parquet-folder/"
#     "--EC2_PUBLIC_IP"    = aws_instance.example_instance.public_ip
#     "JOB_NAME"           = "your_glue_job_name"
#   }

#   script_location = aws_glue_script.glue_script.s3_path
# }











# Define Glue script
# resource "aws_glue_script" "HTC_POC_USECASE2_618580_GLUE_SCRIPT" {
#   name = var.HTC_POC_618580_USECASE_2_GLUE_SCRIPT_NAME
#   language = var.HTC_POC_618580_USECASE_2_GLUE_SCRIPT_LANGUAGE
  
#   script {
#     # Glue script content goes here...
#     # Use the EC2 public IP dynamically in your MySQL connection parameters
#     inline = <<-EOT

#       import sys
#       from awsglue.transforms import *
#       from awsglue.utils import getResolvedOptions
#       from pyspark.context import SparkContext
#       from awsglue.context import GlueContext
#       from awsglue.job import Job
#       from pyspark.sql import SparkSession
 
#       # Get job arguments
#       args = getResolvedOptions(sys.argv, ["JOB_NAME", "S3_CSV_PATH", "S3_PARQUET_PATH", "EC2_PUBLIC_IP"])
 
#       # Initialize Glue context and job
#       sc = SparkContext()
#       glueContext = GlueContext(sc)
#       spark = glueContext.spark_session
#       job = Job(glueContext)
#       job.init(args["JOB_NAME"], args)
 
#       # Read CSV data from S3 into DynamicFrame
#       csv_dynamic_frame = glueContext.create_dynamic_frame.from_options(
#         format_options={
#             "quoteChar": '"',
#             "withHeader": True,
#             "separator": ",",
#             "optimizePerformance": False,
#         },
#         connection_type="s3",
#         format="csv",
#         connection_options={
#             "paths": [args["S3_CSV_PATH"]],
#             "recurse": True,
#         },
#         transformation_ctx="AmazonS3_node",
#       )
 
#       # Write DynamicFrame to S3 in Parquet format
#       parquet_output_path = args["S3_PARQUET_PATH"]
#       glueContext.write_dynamic_frame.from_options(
#         frame=csv_dynamic_frame,
#         connection_type="s3",
#         format="parquet",
#         connection_options={
#             "path": parquet_output_path,
#             "partitionKeys": [],
#         },
#         format_options={"compression": "snappy"},
#         transformation_ctx="AmazonS3_node_parquet",
#       )
 
#       # Commit the job
#       job.commit()
 
#       # Load the latest Parquet file from the Parquet conversion folder
#       latest_parquet_file = spark.read.parquet(parquet_output_path)
 
#       # Define MySQL connection parameters
#       mysql_url = "jdbc:mysql://{args['EC2_PUBLIC_IP']}:3306/customer_db"
#       mysql_properties = {
#         "user": "root",
#         "password": "Admin#123",
#         "driver": "com.mysql.cj.jdbc.Driver",
#       }
#       mysql_table_name = "customer_db"
 
#       # Write Parquet data to MySQL
#       try:
#         latest_parquet_file.write.mode("overwrite").jdbc(url=mysql_url, table=mysql_table_name, properties=mysql_properties)
#         print("Table created successfully.")
#       except Exception as e:
#         print(f"Error writing to MySQL: {str(e)}")
 
#       # Commit the job
#       job.commit()

#     EOT
#   }
# }