# ============================================
# TeleDoc — Terraform Variables
# ============================================

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "teledoc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "app_instance_type" {
  description = "EC2 instance type for App server"
  type        = string
  default     = "t3.micro"
}

variable "monitor_instance_type" {
  description = "EC2 instance type for Monitoring server"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "AWS key pair name for SSH access"
  type        = string
  default     = "teledoc"
}

variable "my_ip" {
  description = "Your public IP for SSH access (CIDR format, e.g., 1.2.3.4/32)"
  type        = string
}

variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "teledoc"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "teledoc_admin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "app_key" {
  description = "Laravel App Key"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email address for ASG notifications"
  type        = string
  default     = "anuragchauhan536@gmail.com"
}
