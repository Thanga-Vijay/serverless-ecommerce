module "apigateway" {
  source = "../modules/apigateway"

  name_prefix                = local.name_prefix
  stage_name                 = var.environment
  routes                     = local.api_routes
  lambda_integrations        = module.lambda.invoke_arns
  cognito_user_pool_endpoint = module.cognito.user_pool_endpoint
  cognito_app_client_id      = module.cognito.app_client_id
  allowed_cors_origins       = var.allowed_cors_origins
  log_retention_days         = var.log_retention_days
  throttling_burst_limit     = var.environment == "prod" ? 1000 : 200
  throttling_rate_limit      = var.environment == "prod" ? 500 : 100
  tags                       = local.common_tags
}
