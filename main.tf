variable "vpc_cidr_range" {}
variable "project_name" {}
variable "private_subnet_cidr_range" {}
variable "public_subnet_cidr_range" {}
variable "alb_port" {}
variable "alb_target_type" {}
variable "alb_protocol" {}
variable "alb_health_check_port" {}
variable "db_port" {}
variable "db_allocated_storage" {}
variable "db_name" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "db_username" {}
variable "db_password" {}
variable "efs_creation_token" {}
variable "efs_encrypted" {}
variable "efs_throughput_mode" {}
variable "efs_performance_mode" {}
variable "container_name" {}
variable "volume_name" {}
variable "container_port" {}
variable "image_name" {}
variable "container_path" {}
variable "task_number" {}
variable "efs_path" {}

# LOCALS
locals {
  region            = var.aws_target_region
  region_substring  = lower(format("%s%s%s", substr(local.region, 0, 2), substr(local.region, 3, 1), substr(local.region, -1, 1)))
  environment       = terraform.workspace
}

//Network module
module "network" {
  source                    = "./modules/network"
  environment               = local.environment
  region_substring          = local.region_substring
  vpc_cidr_range            = var.vpc_cidr_range
  project_name              = var.project_name
  private_subnet_cidr_range = var.private_subnet_cidr_range
  public_subnet_cidr_range  = var.public_subnet_cidr_range
  alb_port                  = var.alb_port
  alb_target_type           = var.alb_target_type
  alb_protocol              = var.alb_protocol
  alb_health_check_port     = var.alb_health_check_port

}

//Data module
module "data" {
  source     = "./modules/data"
  depends_on = [module.network]
  environment               = local.environment
  //DATABASE
  region_substring          = local.region_substring
  data_vpc_id               = module.network.vpc_id
  project_name              = var.project_name
  vpc_cidr_range            = var.vpc_cidr_range
  db_port                   = var.db_port
  db_allocated_storage      = var.db_allocated_storage
  db_name                   = var.db_name
  db_engine                 = var.db_engine
  db_engine_version         = var.db_engine_version
  db_instance_class         = var.db_instance_class
  db_username               = var.db_username
  db_password               = var.db_password
  private_subnet_cidr_range = var.private_subnet_cidr_range

  //EFS
  efs_creation_token   = var.efs_creation_token
  efs_encrypted        = var.efs_encrypted
  efs_throughput_mode  = var.efs_throughput_mode
  efs_performance_mode = var.efs_performance_mode
  efs_path             = var.efs_path 

}

// ECS CLUSTER
module "ecs-cluster" {
  source           = "./modules/ecs-cluster"
  environment      = local.environment
  depends_on       = [module.network, module.data]
  efs_id           = module.data.efs_id
  efs_ap_id        = module.data.efs_ap_id
  db_hostname      = module.data.db_hostname
  db_name          = var.db_name
  target_group_arn = module.network.target_group_arn
  db_username      = var.db_username
  db_password      = var.db_password
  project_name     = var.project_name
  vpc_id           = module.network.vpc_id
  region_substring = local.region_substring
  alb_sg_id        = module.network.alb_sg_id
  alb_id           = module.network.alb_id
  container_name   = var.container_name
  volume_name      = var.volume_name
  container_port   = var.container_port
  image_name       = var.image_name
  container_path   = var.container_path
  task_number      = var.task_number
}
