output "api_gateway_id" {
  description = "HTTP API Gateway ID."
  value       = module.serverless_ecommerce.api_gateway_id
}

output "api_endpoint" {
  description = "HTTP API invoke endpoint."
  value       = module.serverless_ecommerce.api_endpoint
}

output "user_pool_id" {
  description = "Cognito user pool ID."
  value       = module.serverless_ecommerce.user_pool_id
}

output "app_client_id" {
  description = "Cognito app client ID."
  value       = module.serverless_ecommerce.app_client_id
}

output "cognito_domain" {
  description = "Cognito hosted UI domain prefix."
  value       = module.serverless_ecommerce.cognito_domain
}

output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.serverless_ecommerce.distribution_id
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name."
  value       = module.serverless_ecommerce.distribution_domain_name
}

output "dynamodb_table_names" {
  description = "DynamoDB table names."
  value       = module.serverless_ecommerce.dynamodb_table_names
}

output "s3_bucket_names" {
  description = "S3 bucket names."
  value       = module.serverless_ecommerce.s3_bucket_names
}

output "sqs_queue_urls" {
  description = "SQS queue URLs."
  value       = module.serverless_ecommerce.sqs_queue_urls
}

output "sns_topic_arns" {
  description = "SNS topic ARNs."
  value       = module.serverless_ecommerce.sns_topic_arns
}

output "lambda_role_arns" {
  description = "Lambda IAM role ARNs."
  value       = module.serverless_ecommerce.lambda_role_arns
}
