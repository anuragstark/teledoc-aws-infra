# ============================================
# TeleDoc — SNS Notifications
# ============================================

resource "aws_sns_topic" "asg_alerts" {
  name = "${var.project_name}-asg-alerts"
}

resource "aws_sns_topic_subscription" "asg_alerts_email" {
  topic_arn = aws_sns_topic.asg_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
