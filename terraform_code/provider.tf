################################################################################################
# PROVIDER ap-south-1
################################################################################################

terraform {
  required_providers {
    aws = ">= 2.0"
  }
}

provider "aws" {
  alias      = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "ap-south-1"
}


