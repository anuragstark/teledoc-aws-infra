# ============================================
# TeleDoc — IAM Roles & Policies
# ============================================
# EC2 Instance Profile with ECR pull permissions
# Used by App EC2 to pull Docker images from ECR
# ============================================

# --- EC2 Role (for ECR access) ---
resource "aws_iam_role" "ec2_ecr" {
  name = "${var.project_name}-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-ecr-role"
  }
}

# --- ECR Pull Policy ---
resource "aws_iam_role_policy" "ecr_pull" {
  name = "${var.project_name}-ecr-pull-policy"
  role = aws_iam_role.ec2_ecr.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = [
          aws_ecr_repository.frontend.arn,
          aws_ecr_repository.backend.arn
        ]
      }
    ]
  })
}

# --- CloudWatch Logs Policy (for container logs) ---
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name = "${var.project_name}-cloudwatch-logs-policy"
  role = aws_iam_role.ec2_ecr.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:*"
      }
    ]
  })
}

# --- Instance Profile ---
resource "aws_iam_instance_profile" "ec2_ecr" {
  name = "${var.project_name}-ec2-ecr-profile"
  role = aws_iam_role.ec2_ecr.name
}

# --- SSM Get Parameter Policy (for ASG user data) ---
resource "aws_iam_role_policy" "ssm_get" {
  name = "${var.project_name}-ssm-get-policy"
  role = aws_iam_role.ec2_ecr.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/teledoc/prod/*"
      }
    ]
  })
}

# --- Monitor EC2 Role (for Service Discovery) ---
resource "aws_iam_role" "monitor" {
  name = "${var.project_name}-monitor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-monitor-role"
  }
}

resource "aws_iam_role_policy" "ec2_describe" {
  name = "${var.project_name}-ec2-describe-policy"
  role = aws_iam_role.monitor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "monitor" {
  name = "${var.project_name}-monitor-profile"
  role = aws_iam_role.monitor.name
}
