output "efs_id" {
  description = "ID that identigies the Elastic File System (EFS)"
  value       = try(aws_efs_file_system.this.id)
}