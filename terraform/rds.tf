# ============================================
# TeleDoc — RDS MySQL Database
# ============================================
# db.t3.micro (free-tier eligible)
# Automated daily backups with 7-day retention
# Only accessible from App EC2 security group
# ============================================

# --- DB Subnet Group (required for RDS, spans 2 AZs) ---
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# --- RDS MySQL Instance ---
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-mysql"

  # Engine
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.db_instance_class
  parameter_group_name = aws_db_parameter_group.main.name

  # Storage
  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  # Backups — Disabled for Free Tier compliance
  backup_retention_period = 0
  # backup_window           = "21:30-22:00"
  # maintenance_window      = "sun:03:00-sun:04:00"

  # Deletion settings (showcase — easy teardown)
  skip_final_snapshot       = true
  delete_automated_backups  = true
  deletion_protection       = false

  performance_insights_enabled = false

  tags = {
    Name = "${var.project_name}-mysql"
  }
}

# --- DB Parameter Group ---
resource "aws_db_parameter_group" "main" {
  name_prefix = "${var.project_name}-mysql-"
  family      = "mysql8.0"
  description = "TeleDoc MySQL 8.0 parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "max_connections"
    value = "100"
  }

  tags = {
    Name = "${var.project_name}-mysql-params"
  }

  lifecycle {
    create_before_destroy = true
  }
}
