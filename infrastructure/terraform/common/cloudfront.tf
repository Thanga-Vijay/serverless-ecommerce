module "cloudfront" {
  source = "../modules/cloudfront"

  name_prefix                = local.name_prefix
  origin_bucket_domain_name  = module.s3.frontend_bucket_regional_domain_name
  origin_bucket_id           = module.s3.frontend_bucket_id
  log_bucket_domain_name     = module.s3.logs_bucket_domain_name
  response_headers_policy_id = module.security.response_headers_policy_id
  tags                       = local.common_tags

  depends_on = [
    module.s3
  ]
}
