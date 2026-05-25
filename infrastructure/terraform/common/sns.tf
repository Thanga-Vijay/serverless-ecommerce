module "sns" {
  source = "../modules/sns"

  name_prefix         = local.name_prefix
  order_topic_name    = "order-notification-topic"
  email_subscriptions = var.notification_email_subscriptions
  tags                = local.common_tags
}
