# RDS PostgreSQL - Auth Service
resource "aws_db_instance" "auth" {
  identifier             = "${var.project_name}-auth-db"
  engine                 = "postgres"
  engine_version         = var.postgres_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.db_user
  password               = random_password.auth_db_password.result
  db_name                = "authdb"
  publicly_accessible    = false
  skip_final_snapshot    = var.skip_final_snapshot
  multi_az               = var.multi_az
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name        = "${var.project_name}-auth-db"
    Environment = var.environment
  }
}

# RDS PostgreSQL - Flag Service
resource "aws_db_instance" "flag" {
  identifier             = "${var.project_name}-flag-db"
  engine                 = "postgres"
  engine_version         = var.postgres_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.db_user
  password               = random_password.flag_db_password.result
  db_name                = "flagdb"
  publicly_accessible    = false
  skip_final_snapshot    = var.skip_final_snapshot
  multi_az               = var.multi_az
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name        = "${var.project_name}-flag-db"
    Environment = var.environment
  }
}

# RDS PostgreSQL - Targeting Service
resource "aws_db_instance" "targeting" {
  identifier             = "${var.project_name}-targeting-db"
  engine                 = "postgres"
  engine_version         = var.postgres_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.db_user
  password               = random_password.targeting_db_password.result
  db_name                = "targetingdb"
  publicly_accessible    = false
  skip_final_snapshot    = var.skip_final_snapshot
  multi_az               = var.multi_az
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name        = "${var.project_name}-targeting-db"
    Environment = var.environment
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
  }
}

# Security Group para RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
  }
}

# Random passwords for databases
resource "random_password" "auth_db_password" {
  length  = 16
  special = true
}

resource "random_password" "flag_db_password" {
  length  = 16
  special = true
}

resource "random_password" "targeting_db_password" {
  length  = 16
  special = true
}
