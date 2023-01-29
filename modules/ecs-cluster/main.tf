data "aws_region" "current" {}

data "aws_subnets" "app" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Type = "Private"
  }
}

################################################################################
# This is the json file associated to the task definition.
################################################################################
data "template_file" "task_definition" {
  template = "${file("containerDefinitions/wordpress.json")}"
  vars = {
    WOF_RDS_ENDPOINT = var.db_hostname
    DB_USERNAME      = var.db_username
    DB_PASSWORD      = var.db_password
    CW_GROUP         = aws_cloudwatch_log_group.wordpress_taskdefinition_cw.name
    REGION           = data.aws_region.current.name
  }
}

################################################################################
# CW log group. This name is passed into the json file associate to the task 
# definition.
################################################################################
resource "aws_cloudwatch_log_group" "wordpress_taskdefinition_cw" {
  name = "ecs/wordpress_task_definition"

  tags = merge(
    { 
      "Name" = "cw-ecs-${var.environment}-${local.region_substring}"
    }, 
    var.tags
    )
}

################################################################################
# The is the IAM policy to be associated to the IAM execution role
################################################################################
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

################################################################################
# The is the execution IAM role to be associated to the task definition
################################################################################
resource "aws_iam_role" "wordpress_taskdefinition_role" {
  name                = "wordpress_taskdefinition_role"
  assume_role_policy  = data.aws_iam_policy_document.ecs_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemReadOnlyAccess"
  ]

  tags = merge(
    { 
      "Name" = "wordpress_taskdefinition_role" 
    }, 
    var.tags
    )
}

locals {
  region           = data.aws_region.current.name
  region_substring = lower(format("%s%s%s", substr(local.region, 0, 2), substr(local.region, 3, 1), substr(local.region, -1, 1)))
}

################################################################################
# This is the ECS cluster
################################################################################
resource "aws_ecs_cluster" "this" {
  name = "ecs-cluster-${var.environment}-${local.region_substring}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    {
      "Name" = "ecs-cluster-${var.environment}-${local.region_substring}"
    },
    var.tags
  )
}

################################################################################
# This is the ECS cluster capacity provider
################################################################################
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
}

################################################################################
# This is the ECS task definition for the wordpress application
################################################################################
resource "aws_ecs_task_definition" "wordpress_taskdefinition" {
  family                   = "wof"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  depends_on = [
    aws_cloudwatch_log_group.wordpress_taskdefinition_cw
  ]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.wordpress_taskdefinition_role.arn
  volume {
    name = "wordpress"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = var.efs_ap_id
        iam             = "DISABLED"
      }
    }
  }
  container_definitions = data.template_file.task_definition.rendered

  tags = merge(
    {
      "Name" = "ecs-task-definition-${var.environment}-${local.region_substring}"
    },
    var.tags
  )
}

################################################################################
# This is the ECS security group
################################################################################
resource "aws_security_group" "ecs_sg" {
  name        = "ECS_Security_Group"
  description = "ECS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups  = [var.alb_sg_id]
  }

  egress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name" = "ecs-sg-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  ) 
}

################################################################################
# We must associate a rule to the ALB SG, that allows to communicate with the
# ECS SG
################################################################################
resource "aws_security_group_rule" "alb_to_ecs" {
  type                        = "egress"
  from_port                   = 8080
  to_port                     = 8080
  protocol                    = "tcp"
  source_security_group_id    = aws_security_group.ecs_sg.id
  security_group_id           = var.alb_sg_id
}

################################################################################
# This represents the ECS service that allows to create a set of tasks for the
# wordpress application
################################################################################
resource "aws_ecs_service" "wordpress_service" {
  name                              = "svc-wordpress-${var.environment}-${var.region_substring}"
  cluster                           = aws_ecs_cluster.this.arn
  task_definition                   = aws_ecs_task_definition.wordpress_taskdefinition.arn
  health_check_grace_period_seconds = 60
  desired_count                     = 2
  enable_ecs_managed_tags           = true
  propagate_tags                    = "SERVICE"
  platform_version                  = "1.4.0"
  force_new_deployment              = true
  launch_type                       = "FARGATE"
  deployment_controller {
    type = "ECS"
  }
  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:114085016447:targetgroup/tg-wordpress-dev-euw2/3acf03285202e245"
    container_name   = "wordpress"
    container_port   = 8080
  }
  network_configuration {
    subnets          = data.aws_subnets.app.ids
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_sg.id]
  }

  tags = var.tags
}