# ============================================
# TeleDoc — EC2 Instances
# ============================================
# App Server: t2.medium — runs Docker containers
# Monitor Server: t2.micro — runs Prometheus + Grafana
# Both use Amazon Linux 2023 + existing teledoc key pair
# ============================================

# --- Get latest Amazon Linux 2023 AMI ---
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# --- App Server Launch Template (Immutable Infrastructure) ---
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ecr.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
      encrypted   = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/app_user_data.sh.tpl", {
    aws_region         = var.aws_region
    alb_dns_name       = aws_lb.main.dns_name
    db_address         = aws_db_instance.main.address
    db_name            = var.db_name
    db_username        = var.db_username
    docker_compose_b64 = filebase64("${path.module}/../docker-compose.prod.yml")
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-app-server"
      Role = "application"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- App Server Auto Scaling Group ---
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-app-asg"
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]
  
  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-asg"
    propagate_at_launch = true
  }
}

# --- Monitor Server EC2 ---
resource "aws_instance" "monitor" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.monitor_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.monitor.id]
  subnet_id              = aws_subnet.public[1].id
  iam_instance_profile   = aws_iam_instance_profile.monitor.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true

    tags = {
      Name = "${var.project_name}-monitor-root"
    }
  }

  # User data script: install Docker & Docker Compose
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    dnf update -y

    # Install Docker
    dnf install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Install Docker Compose v2
    DOCKER_CONFIG=/usr/local/lib/docker/cli-plugins
    mkdir -p $DOCKER_CONFIG
    curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" -o $DOCKER_CONFIG/docker-compose
    chmod +x $DOCKER_CONFIG/docker-compose

    # Create symlink for docker-compose command
    ln -sf $DOCKER_CONFIG/docker-compose /usr/local/bin/docker-compose

    # Create monitoring directory
    mkdir -p /home/ec2-user/monitoring
    chown ec2-user:ec2-user /home/ec2-user/monitoring

    echo "Monitor server setup complete" > /home/ec2-user/setup.log
  EOF

  tags = {
    Name = "${var.project_name}-monitor-server"
    Role = "monitoring"
  }
}

# --- Elastic IPs (stable public addresses) ---
resource "aws_eip" "monitor" {
  instance = aws_instance.monitor.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-monitor-eip"
  }
}
