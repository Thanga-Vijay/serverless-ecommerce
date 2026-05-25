module "sqs" {
  source = "../modules/sqs"

  name_prefix = local.name_prefix
  queues      = local.queues
  tags        = local.common_tags
}
