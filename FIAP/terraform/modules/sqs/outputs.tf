output "sqs_queue_id" {
  description = "SQS Queue ID"
  value       = aws_sqs_queue.evaluation_queue.id
}

output "sqs_queue_url" {
  description = "SQS Queue URL"
  value       = aws_sqs_queue.evaluation_queue.url
}

output "sqs_queue_arn" {
  description = "SQS Queue ARN"
  value       = aws_sqs_queue.evaluation_queue.arn
}

output "sqs_fifo_queue_id" {
  description = "SQS FIFO Queue ID"
  value       = aws_sqs_queue.evaluation_fifo_queue.id
}

output "sqs_fifo_queue_url" {
  description = "SQS FIFO Queue URL"
  value       = aws_sqs_queue.evaluation_fifo_queue.url
}

output "sqs_dlq_arn" {
  description = "SQS DLQ ARN"
  value       = aws_sqs_queue.evaluation_dlq.arn
}
