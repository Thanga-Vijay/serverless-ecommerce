output "api_gateway_id" {
  description = "HTTP API Gateway ID."
  value       = module.apigateway.api_gateway_id
}

output "api_endpoint" {
  description = "HTTP API invoke endpoint."
  value       = module.apigateway.api_endpoint
}

output "user_pool_id" {
  description = "Cognito user pool ID."
  value       = module.cognito.user_pool_id
}

output "app_client_id" {
  description = "Cognito app client ID."
  value       = module.cognito.app_client_id
}

output "cognito_domain" {
  description = "Cognito hosted UI domain prefix."
  value       = module.cognito.cognito_domain
}

output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.cloudfront.distribution_id
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name."
  value       = module.cloudfront.distribution_domain_name
}

output "dynamodb_table_names" {
  description = "DynamoDB table names keyed by logical table."
  value       = module.dynamodb.table_names
}

output "s3_bucket_names" {
  description = "S3 bucket names."
  value       = module.s3.bucket_names
}

output "sqs_queue_urls" {
  description = "SQS queue URLs keyed by queue."
  value       = module.sqs.queue_urls
}

output "sns_topic_arns" {
  description = "SNS topic ARNs."
  value       = module.sns.topic_arns
}

output "lambda_role_arns" {
  description = "IAM role ARNs keyed by Lambda service."
  value       = module.lambda_iam.lambda_role_arns
}

output "lambda_function_names" {
  description = "Lambda function names keyed by service."
  value       = module.lambda.function_names
}

output "lambda_function_arns" {
  description = "Lambda function ARNs keyed by service."
  value       = module.lambda.function_arns
}

output "lambda_invoke_arns" {
  description = "Lambda invoke ARNs keyed by service."
  value       = module.lambda.invoke_arns
}

output "stepfunction_state_machine_arns" {
  description = "Step Functions state machine ARNs."
  value       = module.stepfunctions.state_machine_arns
}
