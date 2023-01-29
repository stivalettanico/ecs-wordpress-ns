variable "environment" {
  description = "Environment, e.g. dev"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "efs_id" {
  description = "Value of the EFS that must be used by the services"
  type        = string
  default     = ""
}

variable "efs_ap_id" {
  description = "Value of the EFS that must be used by the services"
  type        = string
  default     = ""
}

variable "db_hostname" {
  description = "This is the RDS enpoint value"
  type        = string
  default     = ""
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "project_name" {
  description = "This is the project's name"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "This is the VPC Id to use"
  type        = string
  default     = ""
}

variable "region_substring" {
  description = "This is the region where the VPC resides"
  type        = string
  default     = ""
}

variable "alb_sg_id" {
  description = "The is the ID of the security group associated to the ALB"
  type        = string
  default     = ""
}

variable "alb_id" {
  description = "The ID of the Application Load Balancer"
  type        = string
  default     = ""
}






