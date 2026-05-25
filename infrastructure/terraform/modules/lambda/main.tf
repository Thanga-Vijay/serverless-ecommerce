resource "aws_lambda_function" "this" {
  for_each = var.create_functions ? var.functions : {}

  function_name = "${var.name_prefix}-${each.key}"
  role          = var.execution_role_arn
  handler       = each.value.handler
  runtime       = each.value.runtime
  timeout       = lookup(each.value, "timeout", 30)
  memory_size   = lookup(each.value, "memory_size", 256)
  architectures = lookup(each.value, "architectures", ["arm64"])
  s3_bucket     = each.value.s3_bucket
  s3_key        = each.value.s3_key

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = lookup(each.value, "environment", {})
  }

  tags = var.tags
}

resource "aws_lambda_permission" "apigateway" {
  for_each = aws_lambda_function.this

  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/*"
}
