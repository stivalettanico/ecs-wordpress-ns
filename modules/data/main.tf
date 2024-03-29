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
  name        = "RDS_Security_Group"
  description = "RDS Security Group"
  vpc_id      = var.data_vpc_id

  ingress {
    from_port        = var.db_port
    to_port          = var.db_port
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]
  }

  tags = {
      "Name" = "rds-sg-${var.project_name}-${var.environment}-${var.region_substring}"
  }

}

################################################################################
# RDS subnet group: this is where we deploy the RDS instances (private subnets only)
################################################################################
resource "aws_db_subnet_group" "this" {
  name        = "rds-groups-${var.project_name}${var.environment}-${var.region_substring}"
  subnet_ids  = data.aws_subnets.private.ids
  description = "RDS private subnet groups"
  tags = {
      "Name" = "rds-groups-${var.project_name}-${var.environment}-${var.region_substring}"
  }

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

  tags = {
      "Name" = "rds-instance-${var.project_name}-${var.environment}-${var.region_substring}"
  }

}

################################################################################
# EFS
################################################################################
resource "aws_efs_file_system" "this" {
  creation_token    = var.efs_creation_token
  encrypted         = var.efs_encrypted
  throughput_mode   = var.efs_throughput_mode
  performance_mode  = var.efs_performance_mode   

  tags = {
      "Name" = "efs-${var.project_name}-${var.environment}-${var.region_substring}"
  } 

}

################################################################################
# This is the EFS security group
################################################################################
resource "aws_security_group" "efs_sg" {
  name        = "EFS_Security_Group"
  description = "EFS Security Group"
  vpc_id      = var.data_vpc_id

  ingress {
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]
  }

  tags = {
      "Name" = "efs-sg-${var.project_name}-${var.environment}-${var.region_substring}"
  }
  
}

################################################################################
# This is the EFS mount target
################################################################################
resource "aws_efs_mount_target" "this" {
  count           = length(var.private_subnet_cidr_range)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = element(data.aws_subnets.private.ids, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}


################################################################################
# This is the EFS access point
################################################################################
resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id
  posix_user {
    gid = "1000"
    uid = "1000"
  }
  root_directory {
    creation_info {
      owner_gid = "1000"
      owner_uid = "1000"
      permissions = "0777"

    }
    path = var.efs_path
  }
}