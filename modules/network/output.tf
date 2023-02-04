output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.this.id)
}

output "alb_sg_id" {
  description = "The is the ID of the security group associated to the ALB"
  value       = try(aws_security_group.alb_sg.id)
}

output "alb_id" {
  description = "The ID of the Application Load Balancer"
  value       = try(aws_lb.this.id)
}

output "target_group_arn" {
  description = "The arn of the target group associated to the ALB"
  value       = try(aws_lb_target_group.this.arn)
}




