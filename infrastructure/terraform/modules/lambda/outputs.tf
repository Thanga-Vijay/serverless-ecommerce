output "function_names" {
  description = "Lambda function names keyed by service."
  value       = { for key, function in aws_lambda_function.this : key => function.function_name }
}

output "function_arns" {
  description = "Lambda function ARNs keyed by service."
  value       = { for key, function in aws_lambda_function.this : key => function.arn }
}

output "invoke_arns" {
  description = "Lambda invoke ARNs keyed by service."
  value       = { for key, function in aws_lambda_function.this : key => function.invoke_arn }
}

output "log_group_names" {
  description = "CloudWatch log group names keyed by service."
  value       = { for key, log_group in aws_cloudwatch_log_group.this : key => log_group.name }
}
