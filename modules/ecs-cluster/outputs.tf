output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = aws_ecs_cluster.this.name
}
