module "serverless_ecommerce" {
  source = "../../common"

  project_name                     = var.project_name
  environment                      = "dev"
  aws_region                       = var.aws_region
  owner                            = var.owner
  allowed_cors_origins             = var.allowed_cors_origins
  cognito_callback_urls            = var.cognito_callback_urls
  cognito_logout_urls              = var.cognito_logout_urls
  notification_email_subscriptions = var.notification_email_subscriptions
  log_retention_days               = var.log_retention_days
  alarm_email_topic_arn            = var.alarm_email_topic_arn
  extra_tags                       = var.extra_tags
}
