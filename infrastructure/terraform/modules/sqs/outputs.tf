output "queue_names" {
  description = "SQS queue names keyed by logical queue."
  value       = { for key, queue in aws_sqs_queue.this : key => queue.name }
}

output "queue_arns" {
  description = "SQS queue ARNs keyed by logical queue."
  value       = { for key, queue in aws_sqs_queue.this : key => queue.arn }
}

output "queue_urls" {
  description = "SQS queue URLs keyed by logical queue."
  value       = { for key, queue in aws_sqs_queue.this : key => queue.url }
}

output "dlq_names" {
  description = "SQS DLQ names keyed by logical queue."
  value       = { for key, queue in aws_sqs_queue.dlq : key => queue.name }
}

output "dlq_arns" {
  description = "SQS DLQ ARNs keyed by logical queue."
  value       = { for key, queue in aws_sqs_queue.dlq : key => queue.arn }
}
