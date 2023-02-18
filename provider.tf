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