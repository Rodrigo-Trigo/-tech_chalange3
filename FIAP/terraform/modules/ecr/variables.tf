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

variable "image_tag_mutability" {
  description = "Image tag mutability (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}
