variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "togglemaster"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "delay_seconds" {
  description = "Delay seconds for SQS messages"
  type        = number
  default     = 0
}

variable "max_message_size" {
  description = "Max message size in bytes"
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  description = "Message retention in seconds"
  type        = number
  default     = 1209600 # 14 days
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 30
}

variable "receive_wait_time_seconds" {
  description = "Receive wait time in seconds (long polling)"
  type        = number
  default     = 20
}

variable "max_receive_count" {
  description = "Max receive count before sending to DLQ"
  type        = number
  default     = 3
}
