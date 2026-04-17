output "auth_db_endpoint" {
  description = "Auth DB endpoint"
  value       = aws_db_instance.auth.endpoint
}

output "flag_db_endpoint" {
  description = "Flag DB endpoint"
  value       = aws_db_instance.flag.endpoint
}

output "targeting_db_endpoint" {
  description = "Targeting DB endpoint"
  value       = aws_db_instance.targeting.endpoint
}

output "auth_db_password" {
  description = "Auth DB password"
  value       = random_password.auth_db_password.result
  sensitive   = true
}

output "flag_db_password" {
  description = "Flag DB password"
  value       = random_password.flag_db_password.result
  sensitive   = true
}

output "targeting_db_password" {
  description = "Targeting DB password"
  value       = random_password.targeting_db_password.result
  sensitive   = true
}

output "db_user" {
  description = "Database username"
  value       = var.db_user
}
