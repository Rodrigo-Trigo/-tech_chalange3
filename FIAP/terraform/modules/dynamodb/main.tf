# DynamoDB Table para Analytics
resource "aws_dynamodb_table" "analytics" {
  name           = "${var.project_name}-analytics"
  billing_mode   = var.billing_mode
  hash_key       = "analytics_id"
  range_key      = "timestamp"

  attribute {
    name = "analytics_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  # Índices globais secundários (se necessário)
  global_secondary_index {
    name            = "user_id_index"
    hash_key        = "user_id"
    range_key       = "timestamp"
    projection_type = "ALL"

    read_capacity_units  = var.read_capacity_units
    write_capacity_units = var.write_capacity_units
  }

  # Adicionar atributo user_id para o GSI
  attribute {
    name = "user_id"
    type = "S"
  }

  read_capacity_units  = var.read_capacity_units
  write_capacity_units = var.write_capacity_units

  point_in_time_recovery_specification {
    enabled = var.point_in_time_recovery_enabled
  }

  ttl {
    attribute_name = "expiration_time"
    enabled        = var.ttl_enabled
  }

  tags = {
    Name        = "${var.project_name}-analytics-table"
    Environment = var.environment
  }
}

# Stream specification
resource "aws_dynamodb_table" "analytics_with_stream" {
  name           = "${var.project_name}-analytics-stream"
  billing_mode   = var.billing_mode
  hash_key       = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  read_capacity_units  = var.read_capacity_units
  write_capacity_units = var.write_capacity_units

  stream_specification {
    stream_view_type = "NEW_AND_OLD_IMAGES"
  }

  tags = {
    Name        = "${var.project_name}-analytics-stream-table"
    Environment = var.environment
  }
}
