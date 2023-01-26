data "aws_region" "current" {}

locals {
  region           = data.aws_region.current.name
  region_substring = lower(format("%s%s%s", substr(local.region, 0, 2), substr(local.region, 3, 1), substr(local.region, -1, 1)))
}

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

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
}
