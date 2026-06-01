module "lambda_iam" {
  source = "../modules/iam"

  name_prefix         = local.name_prefix
  lambda_services     = local.lambda_iam_services
  dynamodb_table_arns = module.dynamodb.table_arns
  sqs_queue_arns      = module.sqs.queue_arns
  sns_topic_arns      = module.sns.topic_arns
  s3_bucket_arns      = module.s3.bucket_arns
  tags                = local.common_tags
}
