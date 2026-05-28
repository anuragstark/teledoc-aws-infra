# ============================================
# TeleDoc — Security Groups
# ============================================
# Strict least-privilege access controls
# ALB → App EC2 → RDS (chain of trust)
# Monitor EC2 scrapes App EC2 metrics
# SSH restricted to your IP only
# ============================================

# --- ALB Security Group ---
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- App EC2 Security Group ---
resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-app-"
  description = "Security group for App EC2 instance"
  vpc_id      = aws_vpc.main.id

  # HTTP from ALB only
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH from your IP only
  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Node Exporter from Monitor EC2
  ingress {
    description     = "Node Exporter from Monitor"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.monitor.id]
  }

  # cAdvisor from Monitor EC2
  ingress {
    description     = "cAdvisor from Monitor"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.monitor.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- Monitor EC2 Security Group ---
resource "aws_security_group" "monitor" {
  name_prefix = "${var.project_name}-monitor-"
  description = "Security group for Monitoring EC2 instance"
  vpc_id      = aws_vpc.main.id

  # Grafana from your IP
  ingress {
    description = "Grafana from admin IP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Prometheus from your IP
  ingress {
    description = "Prometheus from admin IP"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # SSH from GitHub Actions (Any IP)
  ingress {
    description = "SSH for GitHub Actions"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-monitor-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- RDS Security Group ---
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  description = "Security group for RDS MySQL - only App EC2 can connect"
  vpc_id      = aws_vpc.main.id

  # MySQL from App EC2 only
  ingress {
    description     = "MySQL from App EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}
