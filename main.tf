variable vpc_cidr_range {}
variable project_name {}
variable private_subnet_cidr_range {}
variable public_subnet_cidr_range {}
variable alb_port {}
variable alb_target_type {}
variable alb_protocol {}
variable alb_health_check_port {}
variable database_port {}

data "aws_region" "current" {}

# LOCALS
locals {
  region           = data.aws_region.current.name
  region_substring = lower(format("%s%s%s", substr(local.region, 0, 2), substr(local.region, 3, 1), substr(local.region, -1, 1)))
  account_name     = "app-dev"
  environment      = "wordpress-dev"
  tags = {
    Account           = local.account_name
    Environment       = local.environment
    ManagedBy         = "terraform"
  }
}

# ECS CLUSTER
/*module "ecs-cluster" {
  source = "./modules/ecs-cluster"

  environment = local.environment

  tags = local.tags
}*/

module "network" {
  source = "./modules/network"

  tags                      = local.tags
  region_substring          = local.region_substring
  vpc_cidr_range            = "${var.vpc_cidr_range}"
  project_name              = "${var.project_name}"
  private_subnet_cidr_range = "${var.private_subnet_cidr_range}"
  public_subnet_cidr_range  = "${var.public_subnet_cidr_range}"
  alb_port                  = "${var.alb_port}"
  alb_target_type           = "${var.alb_target_type}"
  alb_protocol              = "${var.alb_protocol}"  
  alb_health_check_port     = "${var.alb_health_check_port}"

}

module "data" {
  source = "./modules/data"
  depends_on = [module.network]

  tags              = local.tags
  region_substring  = local.region_substring
  data_vpc_id       = module.network.vpc_id
  project_name      = "${var.project_name}"
  database_port     = "${var.database_port}"  
  vpc_cidr_range    = "${var.vpc_cidr_range}"
  
}
