terraform {

  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30"
    }
  }
  
  backend "s3" {
    bucket               = "terraform-state-files"
    workspace_key_prefix = "eu-west-2/wordpress"
    key                  = "aws.tfstate"
    region               = "eu-west-2"
  }
  
}