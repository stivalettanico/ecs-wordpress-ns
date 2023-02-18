variable "data_vpc_id" {
  description = "This is the VPC Id to use"
  type        = string
  default     = ""
}

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

variable "project_name" {
  description = "This is the project's name"
  type        = string
  default     = ""
}

variable "region_substring" {
  description = "This is the region where the VPC resides"
  type        = string
  default     = ""
}

variable "db_port" {
  description = "This is the database port"
  type        = number
  default     = 0
}

variable "vpc_cidr_range" {
  description = "This is the VPC CIDR range we want to use"
  type        = string
  default     = ""
}

variable "db_allocated_storage" {
  description = "The storage to be allocated for the RDS database"
  type        = number
  default     = 0
}

variable "db_name" {
  description = "The database name"
  type        = string
  default     = ""
}

variable "db_engine" {
  description = "The database engine"
  type        = string
  default     = ""
}

variable "db_engine_version" {
  description = "The database engine version"
  type        = string
  default     = ""
}

variable "db_instance_class" {
  description = "The database instance class"
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

variable "private_subnet_cidr_range" {
  description = "The CIDR range to be associated to the private subnets"
  type    = list(string)
  default = []
}

variable "efs_creation_token" {
  description = ""
  type    = string
  default = ""
}

variable "efs_encrypted" {
  description = "EFS encryption: true or false"
  type    = bool
  default = true
}

variable "efs_throughput_mode" {
  description = "EFS throughtput mode"
  type    = string
  default = ""
}

variable "efs_performance_mode" {
  description = "EFS performance mode"
  type    = string
  default = ""
}

variable "efs_path" {
  description = "The EFS path to be used by the container"
  type    = string
  default = ""
}

 

