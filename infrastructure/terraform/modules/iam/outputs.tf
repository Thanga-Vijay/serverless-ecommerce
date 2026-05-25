output "lambda_role_arns" {
  description = "Lambda execution role ARNs keyed by service."
  value       = { for key, role in aws_iam_role.lambda : key => role.arn }
}

output "lambda_role_names" {
  description = "Lambda execution role names keyed by service."
  value       = { for key, role in aws_iam_role.lambda : key => role.name }
}

output "stepfunctions_execution_role_arn" {
  description = "Step Functions execution role ARN."
  value       = aws_iam_role.stepfunctions.arn
}
