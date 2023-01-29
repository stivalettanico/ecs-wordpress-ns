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
  description = ""
  type        = number
  default     = 0
}

variable "db_name" {
  description = ""
  type        = string
  default     = ""
}

variable "db_engine" {
  description = ""
  type        = string
  default     = ""
}

variable "db_engine_version" {
  description = ""
  type        = string
  default     = ""
}

variable "db_instance_class" {
  description = ""
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
  description = ""
  type    = list(string)
  default = []
}

variable "efs_creation_token" {
  description = ""
  type    = string
  default = ""
}

variable "efs_encrypted" {
  description = ""
  type    = bool
  default = true
}

variable "efs_throughput_mode" {
  description = ""
  type    = string
  default = ""
}

variable "efs_performance_mode" {
  description = ""
  type    = string
  default = ""
}

