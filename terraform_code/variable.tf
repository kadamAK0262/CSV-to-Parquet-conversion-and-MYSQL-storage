
variable "access_key" {}
variable "secret_key" {}
# variable "region" {}
variable "aws_account" {}
variable "common_tags" {}



#IAM
variable "policy_name" {}
variable "policy_description" {}
variable "role_name" {}
variable "policy_attachment" {}


#********* {S3} ************ 
variable "HTC_POC_USECASE_618580_BUCKET_NAME" {}
variable "HTC_POC_USECASE_618580_BUCKET_KEY_FOLDER" {}

variable "HTC_POC_USECASE_618580_BUCKET_PARQUET_FOLDER" {}


# **************{ Glue}**************
variable "HTC_POC_618580_USECASE_2_GLUE_NAME" {}

variable "HTC_POC_USECASE_618579_GlueJob_Command_Name" {}
variable "HTC_POC_USECASE_618579_GlueJob_Script_Runtime" {}

# Glue Script 
#  variable "HTC_POC_618580_USECASE_2_GLUE_SCRIPT_NAME" {}
# variable "HTC_POC_618580_USECASE_2_GLUE_SCRIPT_LANGUAGE" {}

# ************** { Ec2 Instance}***************
variable "HTC_POC_618580_USECASE_2_INSTANCE_AMI_ID" {}
variable "HTC_POC_618580_USECASE_2_EC2_INSTANCE_TYPE" {}

variable "HTC_POC_OP_618580_vpc_security_group_ids" {}
variable "HTC_POC_OP_618580_key_name" {}

# ****************{ Lambda function }************
variable "HTC_POC_USECASE2_618580__FileName" {}
variable "HTC_POC_USECASE2_618580_Archive" {}
variable "HTC_POC_USECASE2_618580_LambdaFunction_FileName_archives" {}
variable "HTC_POC_USECASE2_618580_LambdaFunction_FunctionName"{}
variable "HTC_POC_USECASE2_618580_LambdaFunction_Handler"{}
variable "HTC_POC_USECASE2_618580_LambdaFunction_Runtime" {}


# *************{ SNS }************
variable "HTC_POC_USECASE_618580_SNS_NAME" {}
variable "HTC_POC_USECASE_618580_SNS_SUBSCRIPTION_PROTOCOL" {}
variable "HTC_POC_USECASE_618580_SNS_SUBSCRIPTION_ENDPOINT" {}