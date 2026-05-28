# ============================================
# TeleDoc — SSM Parameter Store
# ============================================
# Stores secrets for ASG instances to fetch at boot time

resource "aws_ssm_parameter" "db_password" {
  name        = "/teledoc/prod/db_password"
  description = "Database password"
  type        = "SecureString"
  value       = var.db_password
  overwrite   = true
}

resource "aws_ssm_parameter" "app_key" {
  name        = "/teledoc/prod/app_key"
  description = "Laravel App Key"
  type        = "SecureString"
  value       = var.app_key
  overwrite   = true
}

resource "aws_ssm_parameter" "image_tag" {
  name        = "/teledoc/prod/image_tag"
  description = "Current Docker Image Tag"
  type        = "String"
  value       = "latest"
  overwrite   = true

  lifecycle {
    ignore_changes = [value] # CI/CD will update this value, Terraform shouldn't overwrite it
  }
}
