# 1. Collect container logs and metrics and send them to CloudWatch.
#    (The node role already allows this, see CloudWatchAgentServerPolicy in the eks module.)
resource "aws_eks_addon" "cloudwatch" {
  cluster_name = var.cluster_name
  addon_name   = "amazon-cloudwatch-observability"
}

# 2. Where alerts are sent: an email address.
resource "aws_sns_topic" "alerts" {
  name = "${var.cluster_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# 3. One alarm: email me if the nodes' CPU stays above 80%.
resource "aws_cloudwatch_metric_alarm" "node_cpu" {
  alarm_name          = "${var.cluster_name}-node-cpu-high"
  namespace           = "ContainerInsights"
  metric_name         = "node_cpu_utilization"
  dimensions          = { ClusterName = var.cluster_name }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  depends_on = [aws_eks_addon.cloudwatch]
}