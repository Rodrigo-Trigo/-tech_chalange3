output "analytics_table_name" {
  description = "DynamoDB Analytics table name"
  value       = aws_dynamodb_table.analytics.name
}

output "analytics_table_arn" {
  description = "DynamoDB Analytics table ARN"
  value       = aws_dynamodb_table.analytics.arn
}

output "analytics_stream_table_name" {
  description = "DynamoDB Analytics Stream table name"
  value       = aws_dynamodb_table.analytics_with_stream.name
}

output "analytics_stream_arn" {
  description = "DynamoDB Analytics Stream table ARN"
  value       = aws_dynamodb_table.analytics_with_stream.stream_arn
}
