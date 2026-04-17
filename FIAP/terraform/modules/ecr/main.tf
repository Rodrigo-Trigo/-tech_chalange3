# ECR Repository para Auth Service
resource "aws_ecr_repository" "auth_service" {
  name                 = "${var.project_name}/auth-service"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = "${var.project_name}-auth-service-ecr"
    Environment = var.environment
  }
}

# ECR Repository para Flag Service
resource "aws_ecr_repository" "flag_service" {
  name                 = "${var.project_name}/flag-service"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = "${var.project_name}-flag-service-ecr"
    Environment = var.environment
  }
}

# ECR Repository para Targeting Service
resource "aws_ecr_repository" "targeting_service" {
  name                 = "${var.project_name}/targeting-service"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = "${var.project_name}-targeting-service-ecr"
    Environment = var.environment
  }
}

# ECR Repository para Evaluation Service
resource "aws_ecr_repository" "evaluation_service" {
  name                 = "${var.project_name}/evaluation-service"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = "${var.project_name}-evaluation-service-ecr"
    Environment = var.environment
  }
}

# ECR Repository para Analytics Service
resource "aws_ecr_repository" "analytics_service" {
  name                 = "${var.project_name}/analytics-service"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = "${var.project_name}-analytics-service-ecr"
    Environment = var.environment
  }
}

# Lifecycle policy para manter apenas N imagens recentes
resource "aws_ecr_lifecycle_policy" "auth_service_policy" {
  repository = aws_ecr_repository.auth_service.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "flag_service_policy" {
  repository = aws_ecr_repository.flag_service.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "targeting_service_policy" {
  repository = aws_ecr_repository.targeting_service.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "evaluation_service_policy" {
  repository = aws_ecr_repository.evaluation_service.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "analytics_service_policy" {
  repository = aws_ecr_repository.analytics_service.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
