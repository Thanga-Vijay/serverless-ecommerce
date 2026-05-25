output "topic_arns" {
  description = "SNS topic ARNs keyed by logical topic."
  value = {
    order-notification-topic = aws_sns_topic.order_notifications.arn
  }
}

output "topic_names" {
  description = "SNS topic names keyed by logical topic."
  value = {
    order-notification-topic = aws_sns_topic.order_notifications.name
  }
}
