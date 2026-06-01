output "stepfunctions_log_group_arn" {
  description = "Step Functions log group ARN."
  value       = aws_cloudwatch_log_group.stepfunctions.arn
}
