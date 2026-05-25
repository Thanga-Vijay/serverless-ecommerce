output "function_names" {
  description = "Lambda function names."
  value       = { for key, function in aws_lambda_function.this : key => function.function_name }
}

output "function_arns" {
  description = "Lambda function ARNs."
  value       = { for key, function in aws_lambda_function.this : key => function.arn }
}

output "invoke_arns" {
  description = "Lambda invoke ARNs."
  value       = { for key, function in aws_lambda_function.this : key => function.invoke_arn }
}
