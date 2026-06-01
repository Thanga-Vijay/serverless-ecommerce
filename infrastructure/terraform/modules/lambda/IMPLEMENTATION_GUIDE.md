# Lambda Infrastructure Implementation Guide

Complete step-by-step guide to implement the enhanced Lambda Terraform module for the serverless eCommerce platform.

## Table of Contents

1. [Pre-Implementation](#pre-implementation)
2. [Step 1: Generate Bootstrap ZIP](#step-1-generate-bootstrap-zip)
3. [Step 2: Review Module Files](#step-2-review-module-files)
4. [Step 3: Update Common Configuration](#step-3-update-common-configuration)
5. [Step 4: Deploy Infrastructure](#step-4-deploy-infrastructure)
6. [Step 5: Configure CI/CD](#step-5-configure-cicd)
7. [Verification](#verification)
8. [Troubleshooting](#troubleshooting)

## Pre-Implementation

### Requirements

- Terraform 1.7+
- AWS Provider 5.0+
- AWS CLI configured with credentials
- Python 3.8+ (for bootstrap generation)
- Git workflow setup

### Architecture Review

The implementation follows this architecture:

```
Infrastructure (Terraform)          Code (GitHub Actions)
├─ IAM Roles                        ├─ Build & Test
├─ Lambda Functions                 ├─ Package Services
├─ CloudWatch Logs                  ├─ Deploy Code
├─ Permissions                      └─ Verify
└─ Bootstrap Code
```

## Step 1: Generate Bootstrap ZIP

### Option A: Using Python Script (Recommended)

```bash
cd infrastructure/terraform/modules/lambda
python3 generate_bootstrap.py bootstrap.zip
```

Output:
```
✓ Bootstrap ZIP created: bootstrap.zip

Contents:
  index.js (1.2 KB)
  lambda_function.py (1.1 KB)
  package.json (217 bytes)
  README.md (892 bytes)

File size: 2.45 KB

Add to your Terraform variables.tf or tfvars:
bootstrap_source_code_hash = "..."
```

### Option B: Using Bash Script

```bash
cd infrastructure/terraform/modules/lambda
bash generate_bootstrap.sh bootstrap.zip
```

### Verification

```bash
# Verify ZIP was created
ls -lh bootstrap.zip
unzip -l bootstrap.zip

# Get the source code hash
openssl dgst -sha256 -binary bootstrap.zip | openssl enc -base64
```

## Step 2: Review Module Files

The Lambda module has been enhanced with:

- **main.tf** - Lambda resources, permissions, logging
- **variables.tf** - Input variables with validation
- **outputs.tf** - Lambda details for CI/CD
- **README.md** - Comprehensive module documentation
- **BOOTSTRAP_STRATEGY.md** - Bootstrap pattern explanation
- **DEPLOYMENT_ARCHITECTURE.md** - Complete architecture guide

Review each file:

```bash
cat modules/lambda/main.tf          # Resource definitions
cat modules/lambda/variables.tf     # Input validation
cat modules/lambda/outputs.tf       # Output values
cat modules/lambda/README.md        # Full documentation
```

## Step 3: Update Common Configuration

### 3.1 Update common/locals.tf

The file has been updated with `lambda_services_config` containing all services:

```hcl
lambda_services_config = {
  auth-service = {
    handler   = "index.handler"
    runtime   = "nodejs20.x"
    timeout   = 30
    memory    = 256
    # ... more config
  }
  # ... other services
}
```

Review the additions:
```bash
tail -100 infrastructure/terraform/common/locals.tf
```

### 3.2 Create/Update common/lambda.tf

File created at: `infrastructure/terraform/common/lambda.tf`

This file contains:
- Module call to lambda module
- Service configuration build
- Environment variable setup
- SQS queue integration

Review:
```bash
cat infrastructure/terraform/common/lambda.tf
```

### 3.3 Update common/outputs.tf

New outputs added:
- `lambda_function_names` - Function names by service
- `lambda_function_arns` - Function ARNs by service
- `lambda_invoke_arns` - Invoke ARNs for API Gateway
- `lambda_log_groups` - Log group names
- `lambda_details` - Complete details for CI/CD

Review:
```bash
tail -50 infrastructure/terraform/common/outputs.tf
```

## Step 4: Deploy Infrastructure

### 4.1 Initialize Terraform (if needed)

```bash
cd infrastructure/terraform/common
terraform init
```

### 4.2 Validate Configuration

```bash
cd infrastructure/terraform/common
terraform validate
```

### 4.3 Plan Deployment

```bash
terraform plan -out=lambda.tfplan

# Review the plan
# Should show:
# - Creating aws_cloudwatch_log_group for each service
# - Creating aws_lambda_function for each service
# - Creating aws_lambda_permission for API Gateway
# - Creating aws_lambda_permission for SQS (if applicable)
# - Creating aws_lambda_event_source_mapping (if SQS enabled)
```

### 4.4 Apply Configuration

```bash
terraform apply lambda.tfplan

# Output will show:
# Outputs:
# lambda_function_names = {
#   "auth-service" = "serverless-ecommerce-prod-auth-service"
#   "order-service" = "serverless-ecommerce-prod-order-service"
#   ...
# }
```

### 4.5 Verify Deployment

```bash
# List Lambda functions
aws lambda list-functions --region us-east-1 --query 'Functions[?starts_with(FunctionName, `serverless-ecommerce`)]'

# Check log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/serverless-ecommerce" --region us-east-1

# Invoke a function to verify bootstrap code
aws lambda invoke \
  --function-name serverless-ecommerce-prod-auth-service \
  --region us-east-1 \
  response.json

cat response.json
# Should show 503 status with bootstrap message
```

## Step 5: Configure CI/CD

### 5.1 GitHub Actions Workflow

Create/update `.github/workflows/deploy-lambda.yml`:

```yaml
name: Deploy Lambda Functions

on:
  push:
    branches: [main]
    paths:
      - 'backend/**'
      - '.github/workflows/deploy-lambda.yml'

env:
  AWS_REGION: us-east-1
  ENVIRONMENT: prod

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install Dependencies
        run: |
          cd backend
          npm ci
      
      - name: Build
        run: |
          cd backend
          npm run build
      
      - name: Test
        run: |
          cd backend
          npm run test
      
      - name: Package Lambda Functions
        run: |
          cd backend
          for service in auth product order payment inventory notification upload; do
            mkdir -p dist/${service}-service
            cp -r dist/handlers/${service}/* dist/${service}-service/
            cd dist/${service}-service
            zip -r ../${service}-service.zip .
            cd ../..
          done
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Deploy Lambda Code
        run: |
          PREFIX="serverless-ecommerce-${ENVIRONMENT}"
          
          # Deploy each service
          for service in auth product order payment inventory notification upload; do
            SERVICE_NAME="${service}-service"
            ZIP_FILE="backend/dist/${SERVICE_NAME}.zip"
            
            if [ -f "$ZIP_FILE" ]; then
              echo "Deploying $SERVICE_NAME..."
              aws lambda update-function-code \
                --function-name "${PREFIX}-${service}-service" \
                --zip-file "fileb://${ZIP_FILE}" \
                --region "${AWS_REGION}"
              
              # Wait for update
              sleep 2
            fi
          done
      
      - name: Verify Deployment
        run: |
          PREFIX="serverless-ecommerce-${ENVIRONMENT}"
          
          for service in auth product order; do
            echo "Checking $service..."
            aws lambda get-function-configuration \
              --function-name "${PREFIX}-${service}-service" \
              --region "${AWS_REGION}" \
              --query 'LastModified' \
              --output text
          done
      
      - name: Notify Slack
        if: success()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "✓ Lambda deployment successful",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Lambda Deployment Successful*\nEnvironment: ${{ env.ENVIRONMENT }}\nCommit: ${{ github.sha }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### 5.2 GitHub Secrets

Add required secrets to GitHub Actions:

```bash
# AWS Access Key ID
AWS_ACCESS_KEY_ID

# AWS Secret Access Key
AWS_SECRET_ACCESS_KEY

# Slack Webhook (optional)
SLACK_WEBHOOK
```

### 5.3 GitHub Actions Variables

Add variables:

```bash
# Environment (dev, prod, staging)
ENVIRONMENT=prod

# AWS Region
AWS_REGION=us-east-1
```

## Verification

### 6.1 Verify Infrastructure

```bash
# Check Lambda functions exist
aws lambda list-functions --region us-east-1 \
  --query 'Functions[?starts_with(FunctionName, `serverless-ecommerce`)].[FunctionName,Runtime,MemorySize]' \
  --output table

# Check IAM roles
aws iam list-roles --query 'Roles[?contains(RoleName, `serverless-ecommerce`)].[RoleName]' --output table

# Check CloudWatch logs
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/lambda/serverless-ecommerce" \
  --query 'logGroups[*].[logGroupName,retentionInDays]' \
  --output table
```

### 6.2 Test Lambda Invocation

```bash
# Invoke auth-service
aws lambda invoke \
  --function-name serverless-ecommerce-prod-auth-service \
  --payload '{"body": "{}"}' \
  response.json \
  --region us-east-1

cat response.json | jq .

# Expected response (bootstrap code):
{
  "statusCode": 503,
  "body": {
    "error": "Service Unavailable",
    "message": "Lambda function is initializing..."
  }
}
```

### 6.3 Check CloudWatch Logs

```bash
# Tail logs
aws logs tail /aws/lambda/serverless-ecommerce-prod-auth-service \
  --region us-east-1 \
  --since 5m \
  --follow

# Query logs
aws logs filter-log-events \
  --log-group-name /aws/lambda/serverless-ecommerce-prod-auth-service \
  --start-time $(($(date +%s) - 600)) \
  --region us-east-1 \
  --query 'events[*].message' \
  --output text
```

### 6.4 Verify Terraform Outputs

```bash
cd environments/prod
terraform output lambda_function_names
terraform output lambda_function_arns
terraform output lambda_details
```

## Troubleshooting

### Issue: "bootstrap.zip not found"

**Solution**: Generate it first
```bash
cd modules/lambda
python3 generate_bootstrap.py bootstrap.zip
```

### Issue: "Validation failed: Runtime is not valid"

**Solution**: Update runtime to valid value:
```hcl
runtime = "nodejs20.x"  # Valid
runtime = "nodejs18.x"  # Valid
runtime = "python3.11"  # Valid
```

### Issue: "Permission denied for Lambda execution"

**Solution**: Verify IAM role policy:
```bash
aws iam get-role-policy \
  --role-name serverless-ecommerce-prod-auth-service-role \
  --policy-name serverless-ecommerce-prod-auth-service-policy
```

### Issue: "Terraform shows drift after GitHub Actions deploy"

**Solution**: This is expected! The lifecycle rules prevent Terraform from reverting.
```bash
# Verify lifecycle rules are in place
terraform state show 'module.lambda.aws_lambda_function.this["auth-service"]' | grep lifecycle
```

### Issue: "Lambda code not updating via GitHub Actions"

**Solution**: Verify function names match:
```bash
# Get actual function name
aws lambda list-functions --query 'Functions[*].FunctionName' --output text | grep auth

# Use exact name in GitHub Actions workflow
aws lambda update-function-code \
  --function-name serverless-ecommerce-prod-auth-service \
  --zip-file fileb://dist/auth-service.zip
```

### Issue: "CloudWatch logs not appearing"

**Solution**: Verify log group retention settings:
```bash
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/lambda/serverless-ecommerce-prod-auth-service"
```

## Next Steps

1. **Deploy all services** - Repeat deployment for all environments
2. **Configure monitoring** - Set up CloudWatch alarms
3. **Test API Gateway integration** - Invoke via API Gateway
4. **Set up X-Ray** - Enable distributed tracing
5. **Configure SQS triggers** - For async services
6. **Implement auto-scaling** - If needed
7. **Set up canary deployments** - For gradual rollout

## Related Documentation

- [README.md](README.md) - Module documentation
- [BOOTSTRAP_STRATEGY.md](BOOTSTRAP_STRATEGY.md) - Bootstrap pattern
- [DEPLOYMENT_ARCHITECTURE.md](DEPLOYMENT_ARCHITECTURE.md) - Complete architecture
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)

## Support

For issues or questions:
1. Check the Troubleshooting section
2. Review module documentation
3. Verify AWS IAM permissions
4. Check Terraform state

---

**Last Updated**: June 2026
**Version**: 1.0.0
