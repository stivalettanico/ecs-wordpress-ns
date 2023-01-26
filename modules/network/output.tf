output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.this.id)
}