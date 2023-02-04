provider "aws" {
  region = var.aws_target_region

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_role}"
  }

  default_tags {
    tags = {
      Account     = var.account_name
      Environment = "${var.project_name}-${terraform.workspace}"
      ManagedBy   = "terraform"
    }
  }

}

terraform {
  backend "s3" {
    bucket               = "ns-terraform-state-files"
    workspace_key_prefix = "eu-west-2/wordpress"
    key                  = "aws.tfstate"
    region               = "eu-west-2"
  }
}