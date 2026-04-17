# Configuração do Backend Remoto
# IMPORTANTE: Execute ANTES de usar terraform
# 1. Descomente a configuração do backend
# 2. Execute: terraform init
# 3. Após sucesso, as variáveis de backend podem ser comentadas no código

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Descomente após criar o bucket S3 via modulo/s3-backend
  # backend "s3" {
  #   bucket         = "togglemaster-terraform-state-<ACCOUNT_ID>"
  #   key            = "toolkit/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "togglemaster-terraform-locks"
  # }
}

# Provider AWS
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}

provider "tls" {}

# Módulo: S3 Backend (execute primeiro!)
module "s3_backend" {
  source      = "./modules/s3-backend"
  environment = var.environment
}

# Módulo: Networking
module "networking" {
  source                 = "./modules/networking"
  project_name           = var.project_name
  environment            = var.environment
  vpc_cidr               = var.vpc_cidr
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
}

# Módulo: EKS
module "eks" {
  source                = "./modules/eks"
  project_name          = var.project_name
  environment           = var.environment
  lab_role_name         = var.lab_role_name
  kubernetes_version    = var.kubernetes_version
  subnet_ids            = module.networking.private_subnet_ids
  vpc_id                = module.networking.vpc_id
  instance_types        = var.instance_types
  desired_size          = var.desired_size
  min_size              = var.min_size
  max_size              = var.max_size
}

# Módulo: RDS
module "rds" {
  source             = "./modules/rds"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  vpc_cidr_blocks    = [var.vpc_cidr]
  postgres_version   = var.postgres_version
  instance_class     = var.rds_instance_class
  allocated_storage  = var.allocated_storage
  db_user            = var.db_user
}

# Módulo: ElastiCache
module "elasticache" {
  source             = "./modules/elasticache"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  vpc_cidr_blocks    = [var.vpc_cidr]
  node_type          = var.elasticache_node_type
  num_cache_nodes    = var.elasticache_num_cache_nodes
  redis_engine_version = var.redis_engine_version
}

# Módulo: DynamoDB
module "dynamodb" {
  source                        = "./modules/dynamodb"
  project_name                  = var.project_name
  environment                   = var.environment
  billing_mode                  = var.dynamodb_billing_mode
  read_capacity_units           = var.read_capacity_units
  write_capacity_units          = var.write_capacity_units
  point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
}

# Módulo: SQS
module "sqs" {
  source                        = "./modules/sqs"
  project_name                  = var.project_name
  environment                   = var.environment
  delay_seconds                 = var.sqs_delay_seconds
  message_retention_seconds     = var.message_retention_seconds
  visibility_timeout_seconds    = var.visibility_timeout_seconds
}

# Módulo: ECR
module "ecr" {
  source              = "./modules/ecr"
  project_name        = var.project_name
  environment         = var.environment
  image_tag_mutability = var.image_tag_mutability
  scan_on_push        = var.scan_on_push
}
