terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5"
    }
  }
}

# The generated archive exists only to create each function. GitHub Actions
# replaces it with service code by calling aws lambda update-function-code.
data "archive_file" "bootstrap" {
  type        = "zip"
  source_dir  = "${path.module}/bootstrap"
  output_path = "${path.module}/bootstrap.zip"
}

locals {
  sqs_event_sources = merge([
    for service_name, service in var.lambda_services : {
      for queue_arn in service.sqs_queue_arns :
      "${service_name}:${queue_arn}" => {
        service_name = service_name
        queue_arn    = queue_arn
      }
    }
  ]...)
}

resource "aws_cloudwatch_log_group" "this" {
  for_each = var.lambda_services

  name              = "/aws/lambda/${var.name_prefix}-${each.key}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${each.key}-logs"
    Service = each.key
  })
}

resource "aws_lambda_function" "this" {
  for_each = var.lambda_services

  filename         = data.archive_file.bootstrap.output_path
  source_code_hash = data.archive_file.bootstrap.output_base64sha256
  function_name    = "${var.name_prefix}-${each.key}"
  role             = var.lambda_role_arns[each.key]
  runtime          = each.value.runtime
  handler          = each.value.handler
  timeout          = each.value.timeout
  memory_size      = each.value.memory_size
  architectures    = each.value.architectures

  environment {
    variables = merge(each.value.environment_variables, {
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
      ENVIRONMENT                         = var.environment
      LOG_LEVEL                           = var.log_level
      REGION                              = var.aws_region
      SERVICE_NAME                        = each.key
    })
  }

  tracing_config {
    mode = "Active"
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-${each.key}"
    Service = each.key
  })

  depends_on = [aws_cloudwatch_log_group.this]

  lifecycle {
    # CI/CD owns application packages after the bootstrap deployment.
    ignore_changes = [
      filename,
      source_code_hash,
      last_modified,
    ]
  }
}

# Avoid an API Gateway -> Lambda -> API Gateway dependency cycle by limiting
# invocation to API Gateway resources in the same AWS account.
resource "aws_lambda_permission" "apigateway" {
  for_each = var.lambda_services

  statement_id   = "AllowExecutionFromApiGateway"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.this[each.key].function_name
  principal      = "apigateway.amazonaws.com"
  source_account = var.api_source_account
}

# SQS invokes Lambda through event source mappings, not lambda permissions.
resource "aws_lambda_event_source_mapping" "sqs" {
  for_each = local.sqs_event_sources

  event_source_arn                   = each.value.queue_arn
  function_name                      = aws_lambda_function.this[each.value.service_name].arn
  batch_size                         = var.sqs_batch_size
  maximum_batching_window_in_seconds = var.sqs_batch_window_seconds
  function_response_types            = ["ReportBatchItemFailures"]
}
