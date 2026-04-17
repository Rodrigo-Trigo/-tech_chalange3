output "auth_service_repository_url" {
  description = "Auth Service ECR Repository URL"
  value       = aws_ecr_repository.auth_service.repository_url
}

output "flag_service_repository_url" {
  description = "Flag Service ECR Repository URL"
  value       = aws_ecr_repository.flag_service.repository_url
}

output "targeting_service_repository_url" {
  description = "Targeting Service ECR Repository URL"
  value       = aws_ecr_repository.targeting_service.repository_url
}

output "evaluation_service_repository_url" {
  description = "Evaluation Service ECR Repository URL"
  value       = aws_ecr_repository.evaluation_service.repository_url
}

output "analytics_service_repository_url" {
  description = "Analytics Service ECR Repository URL"
  value       = aws_ecr_repository.analytics_service.repository_url
}
