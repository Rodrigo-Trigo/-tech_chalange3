# SQS Queue para Evaluation Service
resource "aws_sqs_queue" "evaluation_queue" {
  name                       = "${var.project_name}-evaluation-queue"
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  tags = {
    Name        = "${var.project_name}-evaluation-queue"
    Environment = var.environment
  }
}

# SQS FIFO Queue para processamento ordenado (optional)
resource "aws_sqs_queue" "evaluation_fifo_queue" {
  name                       = "${var.project_name}-evaluation.fifo"
  fifo_queue                 = true
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  tags = {
    Name        = "${var.project_name}-evaluation-fifo-queue"
    Environment = var.environment
  }
}

# Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "evaluation_dlq" {
  name                      = "${var.project_name}-evaluation-dlq"
  message_retention_seconds = var.message_retention_seconds

  tags = {
    Name        = "${var.project_name}-evaluation-dlq"
    Environment = var.environment
  }
}

# Redrive policy para conectar a DLQ
resource "aws_sqs_queue_redrive_policy" "evaluation_queue" {
  queue_url       = aws_sqs_queue.evaluation_queue.id
  redrive_policy  = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.evaluation_dlq.arn
    maxReceiveCount     = var.max_receive_count
  })
}
