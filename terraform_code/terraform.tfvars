
# Old htc account
access_key  = "your_aws_access_key"
secret_key  = "your_aws_secret_key"
aws_account = "your_aws_account_no."

# provideraws = ">= 2.0"

common_tags = {
  Name    = "HTC_POC_USECASE2_618580"
  Project = "USECASE_2_PARQUET_CONVERSION_DATA_LOADING"
  Owner   = "AKSHAY_KADAM"
  Creation_date = "01/03/2024"
  Expiration_date = "01/03/2024"
}


# ******{ Iam role }***********

policy_name = "HTC_POC_USECASE_2_618580_POLICY"
policy_description = "grant access to SNS, CloudWatch, lambda "
role_name = "HTC_POC_618580_USECASE_2_RoleName"
policy_attachment = "attaching_polices_to_access_to_lambda"


#***********{ S3-Bucket }*****************
HTC_POC_USECASE_618580_BUCKET_NAME="htc-poc-usecase2-618580-s3buckets"
# HTC_POC_USECASE_618580_BUCKET_KEY_FOLDER= "data/customer.csv"
HTC_POC_USECASE_618580_BUCKET_KEY_FOLDER= "data/"

HTC_POC_USECASE_618580_BUCKET_PARQUET_FOLDER= "parquet/"



# ************** { Glue }*************

HTC_POC_618580_USECASE_2_GLUE_NAME = "HTC_POC_618580_USECASE_2_GLUE"

HTC_POC_USECASE_618579_GlueJob_Command_Name = "glueetl"
HTC_POC_USECASE_618579_GlueJob_Script_Runtime = "Python 3"

# Glue script 
# HTC_POC_618580_USECASE_2_GLUE_SCRIPT_NAME = "HTC_POC_618580_USECASE_2_GLUE_SCRIPT"
# HTC_POC_618580_USECASE_2_GLUE_SCRIPT_LANGUAGE = "PYTHON"


# *************** { Ec2 instance }*************
# HTC_POC_618580_USECASE_2_INSTANCE_AMI_ID = "ami-0c7217cdde317cfec" 
HTC_POC_618580_USECASE_2_INSTANCE_AMI_ID = "ami-03bb6d83c60fc5f7c"
HTC_POC_618580_USECASE_2_EC2_INSTANCE_TYPE = "t2.micro"
# HTC_POC_OP_618580_vpc_security_group_ids = "sg-0de0fe54aa7981258"   # personal account 
# HTC_POC_OP_618580_vpc_security_group_ids = "sg-030ea00978a27084f"   # N. Varginia region          # sg-0f8676af817e3a8ea
HTC_POC_OP_618580_vpc_security_group_ids = "sg-0f8676af817e3a8ea"   # Mumbai region
HTC_POC_OP_618580_key_name  = "awsusecase2_618580_key_pair"


# ************** { Lambda Function }*****************
HTC_POC_USECASE2_618580__FileName = "./Modules/Lambda/LambdaCode/glue_trigger.py"
HTC_POC_USECASE2_618580_Archive = "/Zip/glue_trigger.zip"
HTC_POC_USECASE2_618580_LambdaFunction_FileName_archives = "./Modules/Lambda/Zip/glue_trigger.zip"
HTC_POC_USECASE2_618580_LambdaFunction_FunctionName ="HTC_POC_618580_USECASE2_LAMBDA"
HTC_POC_USECASE2_618580_LambdaFunction_Handler = "glue_trigger.lambda_handler"
HTC_POC_USECASE2_618580_LambdaFunction_Runtime = "python3.12"


#************{ SNS }*********************
HTC_POC_USECASE_618580_SNS_NAME = "HTC_POC_USECASE2_618580_TOPIC"
HTC_POC_USECASE_618580_SNS_SUBSCRIPTION_ENDPOINT = "akshaykadam0262@gmail.com"
HTC_POC_USECASE_618580_SNS_SUBSCRIPTION_PROTOCOL = "email"