# ============================================
# TeleDoc — AWS Certificate Manager (ACM)
# ============================================

resource "aws_acm_certificate" "main" {
  domain_name       = "aws.teledoc.co.in"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-acm-cert"
  }
}
