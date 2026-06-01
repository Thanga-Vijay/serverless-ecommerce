module "monitoring" {
  source = "../modules/monitoring"

  name_prefix           = local.name_prefix
  log_retention_days    = var.log_retention_days
  lambda_function_names = values(module.lambda.function_names)
  api_id                = module.apigateway.api_gateway_id
  sqs_dlq_names         = module.sqs.dlq_names
  dynamodb_table_names  = module.dynamodb.table_names
  alarm_actions         = var.alarm_email_topic_arn == null ? [] : [var.alarm_email_topic_arn]
  tags                  = local.common_tags
}
