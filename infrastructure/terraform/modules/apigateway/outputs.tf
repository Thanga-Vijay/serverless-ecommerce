output "api_gateway_id" {
  description = "HTTP API Gateway ID."
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "HTTP API invoke endpoint."
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "execution_arn" {
  description = "HTTP API execution ARN."
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "access_log_group_arn" {
  description = "API Gateway access log group ARN."
  value       = aws_cloudwatch_log_group.access.arn
}

output "route_ids" {
  description = "Route IDs keyed by logical route name."
  value       = { for key, route in aws_apigatewayv2_route.this : key => route.id }
}
