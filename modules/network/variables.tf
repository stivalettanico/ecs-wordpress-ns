variable "vpc_cidr_range" {
  description = "This is the VPC CIDR range we want to use"
  type        = string
  default     = ""
}

variable "public_subnet_cidr_range" {
  type    = list(string)
  default = []
}

variable "private_subnet_cidr_range" {
  type    = list(string)
  default = []
}

variable "region_substring" {
  description = "This is the region where the VPC resides"
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

variable "alb_port" {
  description = "This is the port where the internet facing alb accept traffic"
  type        = number
  default     = 0
}

variable "alb_protocol" {
  description = "This is the protocol where the internet facing alb accept traffic"
  type        = string
  default     = ""
}

variable "alb_health_check_port" {
  description = "This is the health check port on the backend application used by the ALB"
  type        = number
  default     = 0
}

variable "alb_target_type" {
  description = "This is the target type associated to the alb target group"
  type        = string
  default     = ""
}








