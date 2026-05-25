output "stepfunctions_log_group_arn" {
  description = "Step Functions log group ARN."
  value       = aws_cloudwatch_log_group.stepfunctions.arn
}

output "lambda_log_group_names" {
  description = "Lambda log group names."
  value       = { for key, log_group in aws_cloudwatch_log_group.lambda : key => log_group.name }
}
