# CSV-to-Parquet-conversion-and-MYSQL-storage

This repository contains the code and infrastructure for automating the process of checking the MD5 value of a CSV file uploaded to S3 bucket, converting it into a Parquet file, and storing it in a MySQL database. The project uses various AWS services and Terraform for infrastructure.

Architecture :
The project's architecture revolves around the seamless integration of AWS services to automate the data validation, transformation, and storage process. The key components include:

Amazon S3: Stores the CSV files uploaded by users.
AWS Lambda: Executes the MD5 value check and triggers further processing.
AWS Glue: Converts CSV files into Parquet format.
Amazon EC2: Hosts the MySQL database for storing Parquet files.
Amazon SNS: Sends email notifications for process updates and alerts.

Features :
Automated Validation: Checks the MD5 signature of uploaded CSV files to ensure data integrity.
Format Conversion: Transforms CSV files into efficient Parquet format.
Database Storage: Stores the converted Parquet files in a MySQL database hosted on EC2.
Email Notifications: Notifies users of processing statuses via Amazon SNS.
Infrastructure as Code: Uses Terraform for reproducible and version-controlled infrastructure.

Prerequisites :
Before you begin, ensure you have met the following requirements:

AWS Account
Terraform installed on your local machine
AWS CLI configured with necessary permissions.

Usage :
Once the infrastructure is deployed, follow these steps to use the application:

Upload CSV File: Upload a CSV file to the designated S3 bucket.
MD5 Validation: Lambda function checks the MD5 value of the uploaded file.
Conversion to Parquet: AWS Glue converts the validated CSV file to Parquet format.
Storage in MySQL: The converted Parquet file is stored in the MySQL database hosted on an EC2 instance.
Notifications: SNS sends email notifications about the status of the process.
