module "dynamodb" {
  source = "../modules/dynamodb"

  name_prefix = local.name_prefix
  tables      = local.dynamodb_tables
  tags        = local.common_tags
}
