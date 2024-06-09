import os
import boto3
import logging

# Configure the logging format
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

 
def lambda_handler(event, context):
    try :
    # Fetch Glue job name from environment variable
        glue_job_name = os.environ.get('GLUE_JOB_NAME')
        if not glue_job_name:
            raise ValueError("GLUE_JOB_NAME environment variable is not set.")
   
        # Fetch file key from the S3 event
        file_key = event['Records'][0]['s3']['object']['key']
        print(f"S3 file key: {file_key}")
        logging.info(f"S3 file key: {file_key}")
 
            # Start the Glue job
        glue = boto3.client('glue')
        response = glue.start_job_run(JobName=glue_job_name, Arguments={'--FILE_KEY': file_key})
        print(f"Glue job run response: {response}")
        logging.info(f"Glue job run response: {response}")
 
        # Optionally, you can log or handle the response
        print(f"Started Glue job run: {response['JobRunId']}")
        logging.info(f"Started Glue job run: {response['JobRunId']}")
 
        return {
            'statusCode': 200,
            'body': 'Glue job started successfully.'
        }
    
    except Exception as e:
        # Log any exceptions
        logging.error(f"Error in lambda_handler: {str(e)}")
        raise



# import boto3
# import os
# import time
 
# def lambda_handler(event, context):
#     # Specify your Glue job name
#     # glue_job_name = 'htc-poc-usecase2-gluejob'
#     glue_job_name   = os.environ.get('GLUE_JOB_NAME')
 
#     # Specify the S3 file key from the S3 event
#     file_key = event['Records'][0]['s3']['object']['key']
#     print(f"S3 file key: {file_key}")
 
#     # Start the Glue job
#     glue = boto3.client('glue')
#     time.sleep(30)
#     response = glue.start_job_run(JobName=glue_job_name, Arguments={'--FILE_KEY': file_key})
#     print(f"Glue job run response: {response}")
 
#     # Optionally, you can log or handle the response
#     print(f"Started Glue job run: {response['JobRunId']}")
 
#     return {
#         'statusCode': 200,
#         'body': 'Glue job started successfully.'
#     }