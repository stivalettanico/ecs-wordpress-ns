variable "aws_target_region" {
  description = "this is the region where we want to deploy our application"
  type        = string
  default     = ""
}

variable "aws_account_id" {
  description = "this is the account id where we want to deploy our application"
  type        = string
  default     = ""
}

variable "aws_role" {
  description = "this is the role to be used in order to deploy our application"
  type        = string
  default     = ""
}

variable "account_name" {
  description = "this is the account name where we want to deploy our application"
  type        = string
  default     = ""
}

variable "current_env" {
  description = "this is the environment(workspace) where we want to deploy the application"
  type        = string
  default     = ""
}



