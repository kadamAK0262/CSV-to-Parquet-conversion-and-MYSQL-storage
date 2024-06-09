
################################################################################################
# IAM MODULE
################################################################################################


module "iam" {
  providers = {
    aws = aws.ap-south-1
  }

source = "./Global/role"
policy_attachment = var.policy_attachment
policy_description = var.policy_description
policy_name = var.policy_name
role_name = var.role_name
  
}

#SNS
module "aws_sns_topic" {
    # source = "./Modules/sns"
    source = "./Modules/SNS"
    providers = {
      aws= aws.ap-south-1
    }
    HTC_POC_USECASE_618580_SNS_NAME = var.HTC_POC_USECASE_618580_SNS_NAME
    HTC_POC_USECASE_618580_SNS_SUBSCRIPTION_ENDPOINT =var.HTC_POC_USECASE_618580_SNS_SUBSCRIPTION_ENDPOINT
    HTC_POC_USECASE_618580_SNS_SUBSCRIPTION_PROTOCOL=var.HTC_POC_USECASE_618580_SNS_SUBSCRIPTION_PROTOCOL
    common_tags = var.common_tags
 
}

# S3-Bucket
module "aws_s3_bucket" {

    source = "./Modules/s3Bucket"
    providers = {
        aws =aws.ap-south-1
    }
    HTC_POC_USECASE_618580_BUCKET_NAME = var.HTC_POC_USECASE_618580_BUCKET_NAME
    HTC_POC_USECASE_618580_BUCKET_KEY_FOLDER = var.HTC_POC_USECASE_618580_BUCKET_KEY_FOLDER
    common_tags = var.common_tags
    s3_bucket_mapping_arn = module.aws_s3_bucket.s3_bucket_mapping_arn
    HTC_POC_USECASE_618580_BUCKET_PARQUET_FOLDER =var.HTC_POC_USECASE_618580_BUCKET_PARQUET_FOLDER
    HTC_POC_USECASE2_618580_LambdaFunction_FunctionName = var.HTC_POC_USECASE2_618580_LambdaFunction_FunctionName
    lambda_function_arn = module.aws_lambda_function.lambda_function_arn
    glue_script_folder_name = module.aws_s3_bucket.glue_script_folder_name

}

# Lambda Function 
module "aws_lambda_function" {
  source = "./Modules/Lambda"
  providers = {
    aws = aws.ap-south-1
  }

  HTC_POC_USECASE2_618580__FileName               = var.HTC_POC_USECASE2_618580__FileName
  HTC_POC_USECASE2_618580_Archive                 = var.HTC_POC_USECASE2_618580_Archive
  HTC_POC_USECASE2_618580_LambdaFunction_FileName_archives = var.HTC_POC_USECASE2_618580_LambdaFunction_FileName_archives
  HTC_POC_USECASE2_618580_LambdaFunction_FunctionName     = var.HTC_POC_USECASE2_618580_LambdaFunction_FunctionName
  HTC_POC_USECASE2_618580_LambdaFunction_Handler           = var.HTC_POC_USECASE2_618580_LambdaFunction_Handler
  HTC_POC_USECASE2_618580_LambdaFunction_Runtime           = var.HTC_POC_USECASE2_618580_LambdaFunction_Runtime
  iam_role_arn                                            = module.iam.iam_role_arn

  sns_arn                                         = module.aws_sns_topic.sns_arn
  HTC_POC_USECASE_618580_BUCKET_NAME               = var.HTC_POC_USECASE_618580_BUCKET_NAME
  
  common_tags                                             = var.common_tags

  HTC_POC_618580_USECASE_2_GLUE_NAME = var.HTC_POC_618580_USECASE_2_GLUE_NAME
}


#  Ec2 Instance 

module "aws_ec2_instance" {
  source = "./Modules/ec2_instance"
  providers = {
    aws = aws.ap-south-1

  }

  HTC_POC_618580_USECASE_2_EC2_INSTANCE_TYPE = var.HTC_POC_618580_USECASE_2_EC2_INSTANCE_TYPE
  common_tags = var.common_tags
  HTC_POC_618580_USECASE_2_INSTANCE_AMI_ID = var.HTC_POC_618580_USECASE_2_INSTANCE_AMI_ID
  HTC_POC_OP_618580_vpc_security_group_ids = var.HTC_POC_OP_618580_vpc_security_group_ids
  HTC_POC_OP_618580_key_name = var.HTC_POC_OP_618580_key_name
}

module "aws_glue_job" {
  source = "./Modules/glue"
  providers = {
    aws = aws.ap-south-1
  }

  # HTC_POC_618580_USECASE_2_GLUE_SCRIPT_NAME = var.HTC_POC_618580_USECASE_2_GLUE_SCRIPT_NAME
  HTC_POC_618580_USECASE_2_GLUE_NAME = var.HTC_POC_618580_USECASE_2_GLUE_NAME
  # HTC_POC_618580_USECASE_2_GLUE_SCRIPT_LANGUAGE = var.HTC_POC_618580_USECASE_2_GLUE_SCRIPT_LANGUAGE
  ec2_public_ip = module.aws_ec2_instance.ec2_public_ip
  iam_role_arn  = module.iam.iam_role_arn
  s3_bucket_name = module.aws_s3_bucket.s3_bucket_name
  sns_arn = module.aws_sns_topic.sns_arn
  s3_csv_folder_name = module.aws_s3_bucket.s3_csv_folder_name
  s3_parquet_folder_name = module.aws_s3_bucket.s3_parquet_folder_name
  glue_script_folder_name = module.aws_s3_bucket.glue_script_folder_name
  HTC_POC_USECASE_618579_GlueJob_Script_Runtime = var.HTC_POC_USECASE_618579_GlueJob_Script_Runtime
  HTC_POC_USECASE_618579_GlueJob_Command_Name = var.HTC_POC_USECASE_618579_GlueJob_Command_Name



}