output "efs_id" {
  description = "ID that identigies the Elastic File System (EFS)"
  value       = try(aws_efs_file_system.this.id)
}
output "efs_ap_id" {
  description = "ID that identigies the Elastic File System (EFS) access point to be used by the containers"
  value       = try(aws_efs_access_point.this.id)
}
output "db_hostname" {
  description = "This is the RDS hostname value"
  value = "${aws_db_instance.this.address}"
}