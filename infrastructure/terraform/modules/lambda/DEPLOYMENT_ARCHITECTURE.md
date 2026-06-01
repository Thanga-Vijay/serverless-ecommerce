# Lambda Deployment Architecture

## High-Level Overview

This document explains the complete Terraform Lambda deployment architecture for the serverless eCommerce platform.

## Architecture Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                     GitHub Actions CI/CD                        │
├────────────────────────────────────────────────────────────────┤
│  1. Code Commit → Build → Test → Package                       │
│  2. For each service: zip dist/<service>.zip                   │
│  3. Deploy: aws lambda update-function-code                    │
│  4. Health checks & monitoring                                 │
└────────────────────────────────────────────────────────────────┘
                              ↓
┌────────────────────────────────────────────────────────────────┐
│                      AWS Lambda                                 │
├────────────────────────────────────────────────────────────────┤
│  ┌─ auth-service ─────────────────────────────────────────┐   │
│  │  Runtime: nodejs20.x | Handler: index.handler          │   │
│  │  Memory: 256MB | Timeout: 30s | Arch: arm64           │   │
│  │  IAM Role: serverless-ecommerce-prod-auth-service-role │   │
│  │  Log Group: /aws/lambda/serverless-ecommerce-prod-... │   │
│  │  Env: SERVICE_NAME, ENVIRONMENT, LOG_LEVEL, REGION     │   │
│  └────────────────────────────────────────────────────────┘   │
│  ┌─ product-service ──────────────────────────────────────┐   │
│  │  Runtime: nodejs20.x | Handler: index.handler          │   │
│  │  Memory: 512MB | Timeout: 60s | Arch: arm64           │   │
│  │  IAM Role: serverless-ecommerce-prod-product-service-role  │
│  │  Permissions: API Gateway, S3, DynamoDB, SQS          │   │
│  │  Log Group: /aws/lambda/serverless-ecommerce-prod-... │   │
│  │  Env: SERVICE_NAME, ENVIRONMENT, LOG_LEVEL, REGION     │   │
│  │  DLQ: arn:aws:sqs:.../product-dlq                      │   │
│  └────────────────────────────────────────────────────────┘   │
│  ... (order, payment, inventory, notification, upload)        │
└────────────────────────────────────────────────────────────────┘
                         ↑ ↓
┌────────────────────────────────────────────────────────────────┐
│                  AWS Services (Managed by Terraform)            │
├────────────────────────────────────────────────────────────────┤
│  • DynamoDB Tables (users, products, orders, cart, inventory) │
│  • SQS Queues (order, payment, inventory, notification)       │
│  • SNS Topics (order-notification)                             │
│  • S3 Buckets (product-images, uploads)                        │
│  • API Gateway (HTTP API)                                      │
│  • CloudWatch Logs (retention, monitoring)                     │
└────────────────────────────────────────────────────────────────┘
```

## Service Configuration

Each Lambda service is defined in `locals.lambda_services_config`:

```hcl
lambda_services_config = {
  auth-service = {
    handler   = "index.handler"
    runtime   = "nodejs20.x"
    timeout   = 30
    memory    = 256
    architectures = ["arm64"]
    
    # Service-specific configuration
    tables = ["users"]
    queues = []
    topics = []
    buckets = []
    
    # Optional advanced configuration
    reserved_concurrency = null
    dlq_enabled = false
    ephemeral_storage = 512
  }
  
  product-service = {
    handler   = "index.handler"
    runtime   = "nodejs20.x"
    timeout   = 60
    memory    = 512
    architectures = ["arm64"]
    
    tables = ["products", "inventory"]
    queues = ["inventory-update-queue"]
    topics = []
    buckets = ["product_images"]
    
    reserved_concurrency = 100
    dlq_enabled = true
    ephemeral_storage = 1024
  }
  
  # ... order, payment, inventory, notification services
}
```

## Module Integration Flow

### 1. IAM Module (modules/iam)
- Creates least-privilege roles per service
- Attaches policies for resource access
- Output: lambda_role_arns

### 2. Lambda Module (modules/lambda)
- Creates Lambda functions with bootstrap code
- Creates CloudWatch log groups
- Configures environment variables
- Sets up Lambda permissions
- Ignores code changes from CI/CD
- Output: function_names, function_arns, lambda_details

### 3. Common Configuration (common/)
- Aggregates all modules
- Passes lambda_role_arns to lambda module
- Forwards outputs to environment stacks

### 4. Environment Stack (environments/dev or environments/prod)
- Calls common module
- Outputs Lambda details for CI/CD

## Terraform Configuration Example

### common/lambda.tf

```hcl
locals {
  # Generate bootstrap.zip from script first:
  # cd modules/lambda && bash generate_bootstrap.sh
  
  lambda_services_config = {
    auth-service = {
      handler   = "index.handler"
      runtime   = "nodejs20.x"
      timeout   = 30
      memory    = 256
      tables    = ["users"]
      queues    = []
      topics    = []
      buckets   = []
    }
    product-service = {
      handler   = "index.handler"
      runtime   = "nodejs20.x"
      timeout   = 60
      memory    = 512
      tables    = ["products", "inventory"]
      queues    = ["inventory-update-queue"]
      topics    = []
      buckets   = ["product_images"]
    }
    # ... more services
  }
}

module "lambda" {
  source = "../modules/lambda"

  name_prefix       = local.name_prefix
  environment       = var.environment
  aws_region        = data.aws_region.current.name
  bootstrap_zip_path = "${path.module}/../modules/lambda/bootstrap.zip"
  bootstrap_source_code_hash = filebase64sha256(
    "${path.module}/../modules/lambda/bootstrap.zip"
  )
  
  lambda_role_arns = module.lambda_iam.lambda_role_arns
  
  lambda_services = {
    for service, config in local.lambda_services_config :
    service => {
      handler       = config.handler
      runtime       = config.runtime
      timeout       = config.timeout
      memory_size   = config.memory
      architectures = ["arm64"]
      
      environment_variables = {
        DB_REGION = data.aws_region.current.name
        # Service-specific env vars
      }
      
      sqs_queue_arns = [
        for queue in config.queues :
        module.sqs.queue_arns[queue]
      ]
      
      dead_letter_queue_arn = config.dlq_enabled ? module.sqs.queue_arns["${service}-dlq"] : null
      
      reserved_concurrent_executions = config.reserved_concurrency
      ephemeral_storage_size = config.ephemeral_storage
    }
  }
  
  api_execution_arn = module.apigateway.api_execution_arn
  log_retention_days = var.log_retention_days
  
  tags = local.common_tags
  
  depends_on = [
    module.lambda_iam,
    module.dynamodb,
    module.sqs,
    module.s3
  ]
}
```

## Deployment Workflow

### Phase 1: Infrastructure Setup (Terraform)

```bash
# 1. Generate bootstrap.zip
cd infrastructure/terraform/modules/lambda
bash generate_bootstrap.sh
cd -

# 2. Initialize Terraform
cd infrastructure/terraform/environments/dev
terraform init

# 3. Plan deployment
terraform plan -out=plan.tfplan

# 4. Apply
terraform apply plan.tfplan

# Lambda functions now running with bootstrap code
# All infrastructure ready for code deployment
```

### Phase 2: Application Deployment (GitHub Actions)

```yaml
name: Deploy Lambda

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
      
      - name: Build and Test
        run: |
          npm install
          npm run build
          npm run test
      
      - name: Package Lambda Functions
        run: |
          for service in auth product order payment inventory notification; do
            zip -r dist/${service}-service.zip dist/handlers/${service}/
          done
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy Lambda Code
        run: |
          ENVIRONMENT=prod
          PREFIX=serverless-ecommerce-${ENVIRONMENT}
          
          aws lambda update-function-code \
            --function-name ${PREFIX}-auth-service \
            --zip-file fileb://dist/auth-service.zip
          
          aws lambda update-function-code \
            --function-name ${PREFIX}-product-service \
            --zip-file fileb://dist/product-service.zip
          
          # ... deploy all services
      
      - name: Verify Deployment
        run: |
          aws lambda invoke \
            --function-name serverless-ecommerce-prod-auth-service \
            --payload '{}' \
            response.json
          cat response.json
```

## Environment Variables

Lambda functions receive environment variables at runtime:

```hcl
environment_variables = {
  # System variables (set by Terraform)
  SERVICE_NAME    = "auth-service"
  ENVIRONMENT     = "prod"
  LOG_LEVEL       = "INFO"
  REGION          = "us-east-1"
  
  # Custom application variables
  DB_TABLE_USERS   = "users-table"
  AUTH_TOKEN_TTL   = "3600"
  CORS_ORIGIN      = "https://example.com"
  
  # AWS service references
  QUEUE_URL        = "https://sqs.us-east-1.amazonaws.com/.../queue"
  SNS_TOPIC_ARN    = "arn:aws:sns:us-east-1:...:topic"
  S3_BUCKET        = "product-images-bucket"
}
```

Access in application code:

```javascript
// Node.js
const serviceName = process.env.SERVICE_NAME;
const tableUsers = process.env.DB_TABLE_USERS;
```

```python
# Python
import os
service_name = os.environ['SERVICE_NAME']
table_users = os.environ['DB_TABLE_USERS']
```

## Monitoring and Observability

### CloudWatch Logs

All Lambda logs automatically go to:
```
/aws/lambda/serverless-ecommerce-prod-<service-name>
```

Query logs:
```bash
aws logs tail /aws/lambda/serverless-ecommerce-prod-auth-service --follow
```

### X-Ray Tracing

Enabled automatically for all Lambda functions:
```bash
aws xray get-service-graph --start-time 2026-06-01T10:00:00Z
```

### CloudWatch Alarms

Set up in monitoring module:
```hcl
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = module.lambda.function_names
  
  alarm_name          = "${each.key}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  
  alarm_actions = [var.alarm_email_topic_arn]
  
  dimensions = {
    FunctionName = module.lambda.function_names[each.key]
  }
}
```

## Outputs for CI/CD

The module outputs `lambda_details` for CI/CD integration:

```hcl
lambda_details = {
  "auth-service" = {
    function_name = "serverless-ecommerce-prod-auth-service"
    function_arn  = "arn:aws:lambda:us-east-1:...:function:..."
    invoke_arn    = "arn:aws:lambda:us-east-1:...:function:...:invoke"
    role_arn      = "arn:aws:iam::...:role:..."
    runtime       = "nodejs20.x"
    handler       = "index.handler"
    memory_size   = 256
    timeout       = 30
    log_group     = "/aws/lambda/serverless-ecommerce-prod-auth-service"
  }
  # ... more services
}
```

Export for CI/CD:

```bash
# Output to GitHub Actions
terraform output -json lambda_details > lambda-details.json

# Use in GitHub Actions
echo "::set-output name=lambda-details::$(cat lambda-details.json)"
```

## Version Management

### Lambda Aliases (Optional)

Create stable references to specific versions:

```hcl
resource "aws_lambda_alias" "live" {
  for_each = module.lambda.function_names

  name            = "live"
  function_name   = each.value
  function_version = aws_lambda_function.this[each.key].version
}
```

Invoke via alias:

```bash
aws lambda invoke \
  --function-name serverless-ecommerce-prod-auth-service:live \
  response.json
```

### Canary Deployments

Route percentage of traffic to new version:

```hcl
resource "aws_lambda_alias" "live" {
  for_each = module.lambda.function_names

  name             = "live"
  function_name    = each.value
  function_version = aws_lambda_function.this[each.key].version
  
  routing_config {
    additional_version_weights = {
      aws_lambda_function.this[each.key].version = 0.1  # 10% to new
    }
  }
}
```

## Cost Optimization

### Reserved Concurrency

Guarantee capacity for critical services:

```hcl
reserved_concurrent_executions = 100  # Product service critical
```

### Provisioned Concurrency

Pre-warm Lambda for zero cold starts:

```hcl
provisioned_concurrent_executions = 50  # Auth service hot
```

### Memory Tuning

Balance cost and performance:

```hcl
memory_size = 256   # CPU scales with memory in Lambda
# Higher memory = faster execution = lower duration cost
```

## Troubleshooting

### Lambda function not updating

Check lifecycle rules are applied:
```bash
terraform state show 'module.lambda.aws_lambda_function.this["auth-service"]'
# Should show lifecycle with ignore_changes
```

### Permission denied errors

Verify IAM role has required permissions:
```bash
aws iam get-role-policy \
  --role-name serverless-ecommerce-prod-auth-service-role \
  --policy-name serverless-ecommerce-prod-auth-service-policy
```

### Cold starts high

Increase provisioned concurrency:
```hcl
reserved_concurrent_executions = 50
```

Or use Lambda SnapStart (Java only):
```hcl
snap_start {
  apply_on = "PublishedVersions"
}
```

## References

- [AWS Lambda Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Lambda Deployment Package](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html)
