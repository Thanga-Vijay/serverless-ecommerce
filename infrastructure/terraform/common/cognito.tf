module "cognito" {
  source = "../modules/cognito"

  name_prefix          = local.name_prefix
  callback_urls        = length(var.cognito_callback_urls) > 0 ? var.cognito_callback_urls : ["https://${module.cloudfront.distribution_domain_name}/callback"]
  logout_urls          = length(var.cognito_logout_urls) > 0 ? var.cognito_logout_urls : ["https://${module.cloudfront.distribution_domain_name}/logout"]
  access_token_minutes = 60
  id_token_minutes     = 60
  refresh_token_days   = 30
  tags                 = local.common_tags
}
