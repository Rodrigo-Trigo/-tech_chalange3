output "s3_bucket_id" {
  description = "ID do bucket S3 para terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3 para terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB para Terraform locks"
  value       = aws_dynamodb_table.terraform_lock.name
}
