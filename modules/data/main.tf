################################################################################
# Load the AZs
################################################################################
data "aws_availability_zones" "available" {}

################################################################################
# Load private subnets
################################################################################
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.data_vpc_id]
  }

  tags = {
    Type = "Private"
  }
}

################################################################################
# Availablity zones in a specific region
################################################################################
locals { 
  azs = data.aws_availability_zones.available
}

################################################################################
# This is the RDS security group
################################################################################
resource "aws_security_group" "db_sg" {
  name        = "allow_rds_communication"
  description = "RDS Security Group"
  vpc_id      = var.data_vpc_id

  ingress {
    from_port        = var.db_port
    to_port          = var.db_port
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]
  }

  tags = merge(
    {
      "Name" = "rds-sg-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  ) 
}

################################################################################
# RDS subnet group: this is where we deploy the RDS instances (private subnets only)
################################################################################
resource "aws_db_subnet_group" "this" {
  name        = "rds-groups-${var.project_name}${var.environment}-${var.region_substring}"
  subnet_ids  = "${data.aws_subnets.private.ids}"
  description = "RDS private subnet groups"
  tags = merge(
    {
      "Name" = "rds-groups-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  ) 
}

################################################################################
# RDS database
################################################################################
resource "aws_db_instance" "this" {
  identifier              = "rds-instance-${var.project_name}${var.environment}-${var.region_substring}"
  allocated_storage       = var.db_allocated_storage
  db_name                 = var.db_name
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true

  tags = merge(
    {
      "Name" = "rds-instance-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  ) 
}

################################################################################
# EFS
################################################################################
resource "aws_efs_file_system" "this" {
  creation_token    =  "my-product"
  encrypted         = true
  throughput_mode   = "bursting"
  performance_mode  = "generalPurpose"   

  tags = merge(
    {
      "Name" = "EFS-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  ) 
}

################################################################################
# This is the EFS security group
################################################################################
resource "aws_security_group" "efs_sg" {
  name        = "allow_efs_communication"
  description = "EFS Security Group"
  vpc_id      = var.data_vpc_id

  ingress {
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]
  }

  tags = merge(
    {
      "Name" = "efs-sg-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  ) 
}

resource "aws_efs_mount_target" "this" {
  count           = "${length(var.private_subnet_cidr_range)}"
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = "${element(data.aws_subnets.private.ids, count.index)}"
  security_groups = [aws_security_group.efs_sg.id]
}