# S3 Backend Outputs
output "s3_backend_bucket_id" {
  description = "S3 Bucket ID for Terraform state"
  value       = module.s3_backend.s3_bucket_id
}

output "terraform_state_bucket_name" {
  description = "Terraform state bucket name"
  value       = "togglemaster-terraform-state-${data.aws_caller_identity.current.account_id}"
}

output "terraform_lock_table" {
  description = "DynamoDB table name for Terraform locks"
  value       = module.s3_backend.dynamodb_table_name
}

# Networking Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

# EKS Outputs
output "eks_cluster_id" {
  description = "EKS Cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "EKS Cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

# RDS Outputs
output "auth_db_endpoint" {
  description = "Auth Service DB endpoint"
  value       = module.rds.auth_db_endpoint
}

output "flag_db_endpoint" {
  description = "Flag Service DB endpoint"
  value       = module.rds.flag_db_endpoint
}

output "targeting_db_endpoint" {
  description = "Targeting Service DB endpoint"
  value       = module.rds.targeting_db_endpoint
}

output "db_user" {
  description = "Database username"
  value       = module.rds.db_user
}

# ElastiCache Outputs
output "elasticache_endpoint" {
  description = "ElastiCache endpoint"
  value       = module.elasticache.elasticache_endpoint
}

output "elasticache_port" {
  description = "ElastiCache port"
  value       = module.elasticache.elasticache_port
}

# DynamoDB Outputs
output "dynamodb_analytics_table_name" {
  description = "DynamoDB Analytics table name"
  value       = module.dynamodb.analytics_table_name
}

# SQS Outputs
output "sqs_queue_url" {
  description = "SQS Queue URL"
  value       = module.sqs.sqs_queue_url
}

output "sqs_fifo_queue_url" {
  description = "SQS FIFO Queue URL"
  value       = module.sqs.sqs_fifo_queue_url
}

# ECR Outputs
output "auth_service_ecr_repository_url" {
  description = "Auth Service ECR Repository URL"
  value       = module.ecr.auth_service_repository_url
}

output "flag_service_ecr_repository_url" {
  description = "Flag Service ECR Repository URL"
  value       = module.ecr.flag_service_repository_url
}

output "targeting_service_ecr_repository_url" {
  description = "Targeting Service ECR Repository URL"
  value       = module.ecr.targeting_service_repository_url
}

output "evaluation_service_ecr_repository_url" {
  description = "Evaluation Service ECR Repository URL"
  value       = module.ecr.evaluation_service_repository_url
}

output "analytics_service_ecr_repository_url" {
  description = "Analytics Service ECR Repository URL"
  value       = module.ecr.analytics_service_repository_url
}

# Data source
data "aws_caller_identity" "current" {}
