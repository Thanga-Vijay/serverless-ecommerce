module "lambda" {
  source = "../modules/lambda"

  name_prefix        = local.name_prefix
  environment        = var.environment
  aws_region         = data.aws_region.current.name
  lambda_services    = local.lambda_services
  lambda_role_arns   = module.lambda_iam.lambda_role_arns
  api_source_account = data.aws_caller_identity.current.account_id
  log_retention_days = var.log_retention_days
  tags               = local.common_tags
}
