# ============================================
# TeleDoc — Terraform Outputs
# ============================================
# These values are displayed after terraform apply
# and used by Ansible and GitHub Actions
# ============================================

output "alb_dns_name" {
  description = "ALB DNS name — CNAME aws.teledoc.co.in to this"
  value       = aws_lb.main.dns_name
}


output "monitor_server_public_ip" {
  description = "Monitor EC2 public IP (for SSH and Ansible)"
  value       = aws_eip.monitor.public_ip
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://${aws_eip.monitor.public_ip}:3000"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_eip.monitor.public_ip}:9090"
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint (host:port)"
  value       = aws_db_instance.main.endpoint
}

output "rds_hostname" {
  description = "RDS MySQL hostname only (for .env DB_HOST)"
  value       = aws_db_instance.main.address
}

output "ecr_frontend_url" {
  description = "ECR repository URL for frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_url" {
  description = "ECR repository URL for backend"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_registry" {
  description = "ECR registry URL (account.dkr.ecr.region.amazonaws.com)"
  value       = split("/", aws_ecr_repository.frontend.repository_url)[0]
}

output "acm_dns_validation_records" {
  description = "DNS records to add to Hostinger for SSL Validation"
  value = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      Name  = dvo.resource_record_name
      Type  = dvo.resource_record_type
      Value = dvo.resource_record_value
    }
  }
}
