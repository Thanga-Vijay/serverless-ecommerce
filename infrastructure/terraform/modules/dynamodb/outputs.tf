output "table_names" {
  description = "DynamoDB table names keyed by logical table."
  value       = { for key, table in aws_dynamodb_table.this : key => table.name }
}

output "table_arns" {
  description = "DynamoDB table ARNs keyed by logical table."
  value       = { for key, table in aws_dynamodb_table.this : key => table.arn }
}

output "stream_arns" {
  description = "DynamoDB stream ARNs keyed by logical table."
  value       = { for key, table in aws_dynamodb_table.this : key => table.stream_arn if table.stream_enabled }
}
