# Lambda Infrastructure Module

This module creates AWS Lambda infrastructure for the ecommerce services while
leaving application package deployment to CI/CD.

## Managed By Terraform

- Lambda functions
- CloudWatch log groups and retention
- Runtime, handler, memory, timeout, and environment variables
- X-Ray tracing configuration
- API Gateway invocation permissions
- SQS event source mappings
- Tags

## Managed By GitHub Actions

- Service build and tests
- ZIP packaging
- Code updates through `aws lambda update-function-code`

## Bootstrap Package

The module packages `bootstrap/index.js` with the `archive_file` data source.
The placeholder responds with HTTP `503` until the backend workflow deploys
service code.

## Example Usage

```hcl
module "lambda" {
  source = "../modules/lambda"

  name_prefix        = local.name_prefix
  environment        = var.environment
  aws_region         = data.aws_region.current.name
  lambda_services    = local.lambda_services
  lambda_role_arns   = module.lambda_iam.lambda_role_arns
  api_source_account = data.aws_caller_identity.current.account_id
  log_retention_days = var.log_retention_days
  tags               = local.common_tags
}
```

## Example Service

```hcl
auth-service = {
  runtime               = "nodejs20.x"
  handler               = "index.handler"
  timeout               = 15
  memory_size           = 256
  environment_variables = {}
  sqs_queue_arns         = []
}
```

## Outputs

- `function_names`
- `function_arns`
- `invoke_arns`
- `log_group_names`
