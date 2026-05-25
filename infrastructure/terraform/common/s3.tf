module "s3" {
  source = "../modules/s3"

  name_prefix     = local.s3_name_prefix
  frontend_bucket = "frontend-assets"
  product_bucket  = "product-images"
  terraform_bucket = "tf-state-bucket-sls"
  force_destroy   = var.environment != "prod"
  allowed_origins = var.allowed_cors_origins
  tags            = local.common_tags
}

module "frontend_bucket_policy" {
  source = "../modules/s3_bucket_policy"

  frontend_bucket_id          = module.s3.frontend_bucket_id
  frontend_bucket_arn         = module.s3.frontend_bucket_arn
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
}
