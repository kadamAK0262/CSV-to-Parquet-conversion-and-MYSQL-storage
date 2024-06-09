import sys
import os
import hashlib
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import * 
import boto3
import json
import datetime
import logging

# Configure the logging format
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
 
      # Get job arguments
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'FILE_KEY', 'SNS_ARN', 'S3_PARQUET_PATH', 'S3_BUCKET_NAME', 'EC2_PUBLIC_IP'])
#  'S3_PARQUET_PATH'
      # Specify your S3 bucket
s3_bucket = args['S3_BUCKET_NAME']
 
      # Initialize Spark and Glue contexts
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
 
      # SNS Configuration
sns_client = boto3.client('sns')
sns_topic_arn = args['SNS_ARN']  # Replace with your SNS topic ARN
 
      # Function to notify SNS
def notify_sns(message):
    if sns_topic_arn:
        sns_client.publish(TopicArn=sns_topic_arn, Message=message, Subject="S3 Data Integrity Check")
    else:
        print(f"SNS topic ARN not provided. Unable to send notification. Message: {message}")
        logging.error(f"SNS topic ARN not provided. Unable to send notification. Message: {message}")
 
      # Function to move file to folder
def move_file_to_folder(file_key, folder):
    s3_client = boto3.client('s3')
    s3_client.copy_object(Bucket=s3_bucket, CopySource=f"{s3_bucket}/{file_key}", Key=f"{folder}{os.path.basename(file_key)}")
    logging.info(f"Moved file {file_key} to folder {folder}")
 
      # Function to convert CSV to Parquet
def convert_csv_to_parquet(file_key):
          # Convert CSV to Parquet logic here
          # For example, read CSV into DataFrame and write it to Parquet
    df = spark.read.option("header", "true").csv(f"s3://{s3_bucket}/{file_key}")
 
          # Write DataFrame to Parquet
    parquet_output_path = f"{args['S3_PARQUET_PATH']}{os.path.splitext(os.path.basename(file_key))[0]}.parquet"
    df.write.parquet(parquet_output_path, mode="overwrite", compression="snappy")
#     parquet_output_path = f"s3://{s3_bucket}/csv-parquet-conversion/{os.path.splitext(os.path.basename(file_key))[0]}.parquet"
#     df.write.parquet(parquet_output_path, mode="overwrite", compression="snappy")
    print(f"Converted and uploaded {file_key} to {parquet_output_path}")
    logging.info(f"Converted and uploaded {file_key} to {parquet_output_path}")
 
      # Function to compute MD5 checksum
def compute_md5(buffer, s3_client):
    md5 = hashlib.md5()
    md5.update(buffer)
    return md5.hexdigest()


# Function to update bookmark
# def update_bookmark(bookmark_key, value):
#     s3_client = boto3.client('s3')
#     s3_client.put_object(Bucket=s3_bucket, Key=bookmark_key, Body=value)
#     logging.info(f"Bookmark updated: {value}")
def update_bookmark(bookmark_key, file_key):
    s3_client = boto3.client('s3')
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    execution_info = f"Execution Time: {timestamp}\nProcessed File: {file_key}\n"
    s3_client.put_object(Bucket=s3_bucket, Key=bookmark_key, Body=file_key)
    logging.info(f"Bookmark updated: {execution_info}")
 
# Function to retrieve bookmark
def get_bookmark(bookmark_key):
    s3_client = boto3.client('s3')
    try:
        response = s3_client.get_object(Bucket=s3_bucket, Key=bookmark_key)
        return response['Body'].read().decode('utf-8')
    except s3_client.exceptions.NoSuchKey:
        return None


      # Process CSV file
def process_csv_file(file_key):
    try:
        print(f"Processing CSV file: {file_key}")
        logging.info(f"Processing CSV file: {file_key}")
        
 
        # Fetch ETag (MD5 hash) value from the file
        s3_client = boto3.client('s3')
        etag = s3_client.head_object(Bucket=s3_bucket, Key=file_key)['ETag'].strip('"')
 
        # Calculate MD5 hash value from the content
        response = s3_client.get_object(Bucket=s3_bucket, Key=file_key)
        content_md5_hash = compute_md5(response['Body'].read(), s3_client)
 
        # Compare ETag (MD5 hash) with calculated MD5 hash
        if etag.lower() == content_md5_hash.lower():
            print(f"MD5 hashes match for file: {file_key}")
            logging.info(f"MD5 hashes match for file: {file_key}")
            # Notify through SNS
            notify_sns(f"New CSV file detected: {file_key}")
 
            # Move the file to the 'processed' folder
            move_file_to_folder(file_key, 'processed/')
 
            # Convert CSV to Parquet
            convert_csv_to_parquet(file_key)

            # Update bookmark
            update_bookmark('bookmark.txt', file_key)
 
            # Load the Parquet file into MySQL (Placeholder, adapt based on your MySQL configuration)
            # Define MySQL connection parameters
            ec2_public_ip = args['EC2_PUBLIC_IP']
            mysql_url = f"jdbc:mysql://{ec2_public_ip}:3306/customer_db"
            # mysql_url = "jdbc:mysql://{args['EC2_PUBLIC_IP']}:3306/customer_db"
            mysql_properties = {
                "user": "root",
                "password": "Admin#123",
                "driver": "com.mysql.cj.jdbc.Driver",
            }
            mysql_table_name = "customer_table"
            logging.info(f"EC2_PUBLIC_IP: {args['EC2_PUBLIC_IP']}")
            logging.info(f"ec2_public_ip  : {ec2_public_ip}")

            try:
                # Read Parquet file into DataFrame
                parquet_output_path = f"{args['S3_PARQUET_PATH']}{os.path.splitext(os.path.basename(file_key))[0]}.parquet"
                parquet_df = spark.read.parquet(parquet_output_path)
                # parquet_output_path = f"s3://{s3_bucket}/csv-parquet-conversion/{os.path.splitext(os.path.basename(file_key))[0]}.parquet"
                # parquet_df = spark.read.parquet(parquet_output_path)
 
                # Write DataFrame to MySQL
                logging.info("Attempting to write data to MySQL...")
                parquet_df.write.mode("overwrite").jdbc(url=mysql_url, table=mysql_table_name, properties=mysql_properties)
                print("Data loaded into MySQL successfully.")
                logging.info("Data loaded into MySQL successfully.")
            except Exception as e:
                print(f"Error writing to MySQL: {str(e)}")
                logging.error(f"Error writing to MySQL: {str(e)}")
                # Optionally, you can log or handle the error here
 
        else:
            print(f"MD5 hashes do not match for file: {file_key}")
            logging.error(f"MD5 hashes do not match for file: {file_key}")
            # Notify SNS about the error
            notify_sns(f"Error: Data corrupted or lost for file: {file_key}")
            # Move the file to the 'unmatched' folder
            move_file_to_folder(file_key, 'unmatched/')
 
    except Exception as e:
        print(f"Error processing CSV file: {str(e)}")
        logging.error(f"Error processing CSV file: {str(e)}")                       
        # Notify SNS about the error
        notify_sns(f"Error processing CSV file: {str(e)}")
 
      # Extract FILE_KEY from job arguments
file_key = args['FILE_KEY']

# Retrieve bookmark
bookmark = get_bookmark('bookmark.txt')
if bookmark is None or bookmark == '':
    logging.info("No bookmark found. Processing all files.")
    process_csv_file(file_key)
elif file_key > bookmark:
    logging.info(f"Processing new files since bookmark: {bookmark}")
    process_csv_file(file_key)
else:
    logging.info(f"Skipping file: {file_key} (already processed)")
 
      # Call the process_csv_file function
# process_csv_file(file_key)
 
      # Commit the job
job.commit()





















# import sys
# import os
# import hashlib
# from awsglue.transforms import *
# from awsglue.utils import getResolvedOptions
# from pyspark.context import SparkContext
# from awsglue.context import GlueContext
# from awsglue.job import Job
# from awsglue.dynamicframe import DynamicFrame
# from pyspark.sql.functions import *
# import boto3

# import logging

# # Configure the logging format
# logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
 
#       # Get job arguments
# args = getResolvedOptions(sys.argv, ['JOB_NAME', 'FILE_KEY', 'SNS_ARN', 'S3_PARQUET_PATH', 'S3_BUCKET_NAME', 'EC2_PUBLIC_IP'])
# #  'S3_PARQUET_PATH'
#       # Specify your S3 bucket
# s3_bucket = args['S3_BUCKET_NAME']
 
#       # Initialize Spark and Glue contexts
# sc = SparkContext()
# glueContext = GlueContext(sc)
# spark = glueContext.spark_session
# job = Job(glueContext)
# job.init(args['JOB_NAME'], args)
 
#       # SNS Configuration
# sns_client = boto3.client('sns')
# sns_topic_arn = args['SNS_ARN']  # Replace with your SNS topic ARN
 
#       # Function to notify SNS
# def notify_sns(message):
#       if sns_topic_arn:
#             sns_client.publish(TopicArn=sns_topic_arn, Message=message, Subject="S3 Data Integrity Check")
#       else:
#             print(f"SNS topic ARN not provided. Unable to send notification. Message: {message}")
#             logging.error(f"SNS topic ARN not provided. Unable to send notification. Message: {message}")
 
#       # Function to move file to folder
# def move_file_to_folder(file_key, folder):
#       s3_client = boto3.client('s3')
#       s3_client.copy_object(Bucket=s3_bucket, CopySource=f"{s3_bucket}/{file_key}", Key=f"{folder}{os.path.basename(file_key)}")
#       logging.info(f"Moved file {file_key} to folder {folder}")
 
#       # Function to convert CSV to Parquet
# def convert_csv_to_parquet(file_key):
#           # Convert CSV to Parquet logic here
#           # For example, read CSV into DataFrame and write it to Parquet
#       df = spark.read.option("header", "true").csv(f"s3://{s3_bucket}/{file_key}")
 
#           # Write DataFrame to Parquet
#       parquet_output_path = f"{args['S3_PARQUET_PATH']}/{os.path.splitext(os.path.basename(file_key))[0]}.parquet"
#       df.write.parquet(parquet_output_path, mode="overwrite", compression="snappy")
# #     parquet_output_path = f"s3://{s3_bucket}/csv-parquet-conversion/{os.path.splitext(os.path.basename(file_key))[0]}.parquet"
# #     df.write.parquet(parquet_output_path, mode="overwrite", compression="snappy")
#       print(f"Converted and uploaded {file_key} to {parquet_output_path}")
#       logging.info(f"Converted and uploaded {file_key} to {parquet_output_path}")
 
#       # Function to compute MD5 checksum
# def compute_md5(buffer, s3_client):
#       md5 = hashlib.md5()
#       md5.update(buffer)
#       return md5.hexdigest()
 
#       # Process CSV file
# def process_csv_file(file_key):
#       try:
#             print(f"Processing CSV file: {file_key}")
#             logging.info(f"Processing CSV file: {file_key}")
 
#               # Fetch ETag (MD5 hash) value from the file
#             s3_client = boto3.client('s3')
#             etag = s3_client.head_object(Bucket=s3_bucket, Key=file_key)['ETag'].strip('"')
 
#               # Calculate MD5 hash value from the content
#             response = s3_client.get_object(Bucket=s3_bucket, Key=file_key)
#             content_md5_hash = compute_md5(response['Body'].read(), s3_client)
 
#               # Compare ETag (MD5 hash) with calculated MD5 hash
#             if etag.lower() == content_md5_hash.lower():
#                   print(f"MD5 hashes match for file: {file_key}")
#                   logging.info(f"MD5 hashes match for file: {file_key}")
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
#                         "user": "root",
#                         "password": "Admin#123",
#                         "driver": "com.mysql.cj.jdbc.Driver",
#                   }
#                   mysql_table_name = "customer_table"
 
#                   try:
#                       # Read Parquet file into DataFrame
#                         parquet_output_path = f"{args['S3_PARQUET_PATH']}/{os.path.splitext(os.path.basename(file_key))[0]}.parquet"
#                         parquet_df = spark.read.parquet(parquet_output_path)
#             #     parquet_output_path = f"s3://{s3_bucket}/csv-parquet-conversion/{os.path.splitext(os.path.basename(file_key))[0]}.parquet"
#             #     parquet_df = spark.read.parquet(parquet_output_path)
 
#                       # Write DataFrame to MySQL
#                         parquet_df.write.mode("overwrite").jdbc(url=mysql_url, table=mysql_table_name, properties=mysql_properties)
#                         print("Data loaded into MySQL successfully.")
#                         logging.info("Data loaded into MySQL successfully.")
#                   except Exception as e:
#                         print(f"Error writing to MySQL: {str(e)}")
#                         logging.error(f"Error writing to MySQL: {str(e)}")
#                       # Optionally, you can log or handle the error here
 
#             else:
#                   print(f"MD5 hashes do not match for file: {file_key}")
#                   logging.error(f"MD5 hashes do not match for file: {file_key}")
#                   # Notify SNS about the error
#                   notify_sns(f"Error: Data corrupted or lost for file: {file_key}")
#                   # Move the file to the 'unmatched' folder
#                   move_file_to_folder(file_key, 'unmatched/')
 
#       except Exception as e:
#             print(f"Error processing CSV file: {str(e)}")
#             logging.error(f"Error processing CSV file: {str(e)}")                       
#               # Notify SNS about the error
#             notify_sns(f"Error processing CSV file: {str(e)}")
 
#       # Extract FILE_KEY from job arguments
# file_key = args['FILE_KEY']
 
#       # Call the process_csv_file function
# process_csv_file(file_key)
 
#       # Commit the job
# job.commit()