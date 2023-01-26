data "aws_availability_zones" "available" {}


locals {
  # availablity zones in a specific region
  azs = data.aws_availability_zones.available
}

################################################################################
# VPC
################################################################################
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_range 

  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true  

  tags = merge(
    {
      "Name" = "vpc-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  )
}


################################################################################
# Private subnets
################################################################################
resource "aws_subnet" "private" {
  count                   = "${length(var.private_subnet_cidr_range)}"
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${var.private_subnet_cidr_range[count.index]}"
  availability_zone       = "${local.azs.names[count.index]}"
  map_public_ip_on_launch = false

  tags = merge(
    {
      "Name" = "subnet-${var.project_name}${var.environment}-${local.azs.names[count.index]}-priv"
      "Type" = "Private"
    },
    var.tags
  )  
}

################################################################################
# Public subnets
################################################################################
resource "aws_subnet" "public" {
  count                   = "${length(var.public_subnet_cidr_range)}"
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${var.public_subnet_cidr_range[count.index]}"
  availability_zone       = "${local.azs.names[count.index]}"
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = "subnet-${var.project_name}${var.environment}-${local.azs.names[count.index]}-pub"
      "Type" = "Public"
    },
    var.tags
  )  
}

################################################################################
# Internet gateway
################################################################################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "igw-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  ) 
}

################################################################################
# Creates a public route table to be associated with public subnets
################################################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    {
      "Name" = "rt-${var.project_name}${var.environment}-${var.region_substring}-pub"
    },
    var.tags
  ) 
}

//Create elastic IP addresses to be associated with the NAT. We create one EIP for each public subnet to implement HA.
resource "aws_eip" "this" {
  count = "${length(var.public_subnet_cidr_range)}"
  vpc   = true

  tags = merge(
    {
      "Name" = "eip-${var.project_name}${var.environment}-${var.region_substring}-${local.azs.names[count.index]}"
    },
    var.tags
  ) 
}

//Create a NAT gateway in each public subnet
resource "aws_nat_gateway" "this" {
  count           = "${length(var.public_subnet_cidr_range)}"
  allocation_id   = "${element(aws_eip.this.*.id, count.index)}"
  subnet_id       = "${element(aws_subnet.public.*.id, count.index)}"

  tags = merge(
    {
      "Name" = "nat-${var.project_name}${var.environment}-${local.azs.names[count.index]}"
    },
    var.tags
  ) 

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.this]
}

//Associate the route table to the public subnets.
resource "aws_route_table_association" "public" {
  count           = "${length(var.public_subnet_cidr_range)}"
  subnet_id       = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id  = "${aws_route_table.public.id}"
}

//NACL to be associated to the public internet
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.this.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = merge(
    {
      "Name" = "nacl-${var.project_name}${var.environment}-${var.region_substring}-pub"
    },
    var.tags
  ) 
}

resource "aws_network_acl_association" "public" {
  count           = "${length(var.public_subnet_cidr_range)}"
  network_acl_id  = aws_network_acl.public.id
  subnet_id       = "${element(aws_subnet.public.*.id, count.index)}"
}

//Create a private route table to be associated with private subnets. Calls will be send to the NAT gateway
resource "aws_route_table" "private" {
  count  = "${length(var.private_subnet_cidr_range)}"
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.this.*.id, count.index)}"
  }

  tags = merge(
    {
      "Name" = "rt-${var.project_name}${var.environment}-${var.region_substring}-priv-${count.index}"
    },
    var.tags
  ) 
}

resource "aws_route_table_association" "private" {
  count           = "${length(var.private_subnet_cidr_range)}"
  subnet_id       = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

//This is the ALB security group
resource "aws_security_group" "alb_sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port        = var.alb_port
    to_port          = var.alb_port
    protocol         = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name" = "alb-sg-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  ) 
}

//This is the internet facing load balancer.
resource "aws_lb" "this" {
  name               = "alb-${var.project_name}${var.environment}-${var.region_substring}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = merge(
    {
      "Name" = "alb-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  ) 
}

//ALB target group
resource "aws_lb_target_group" "this" {
  name        = "tg-${var.project_name}${var.environment}-${var.region_substring}"
  vpc_id      = aws_vpc.this.id
  port        = var.alb_port
  protocol    = var.alb_protocol
  target_type = var.alb_target_type
  health_check {
    port = var.alb_health_check_port
  } 

  tags = merge(
    {
      "Name" = "tg-${var.project_name}${var.environment}-${var.region_substring}"
    },
    var.tags
  ) 
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.alb_port
  protocol          = var.alb_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}