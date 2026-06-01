# Backend Setup Guide

## Prerequisites

- Node.js 18+ installed
- AWS CLI configured
- Terraform (for infrastructure)
- Serverless Framework CLI (`npm install -g serverless`)

## Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

This installs dependencies for all microservices using workspaces.

### 2. Set Up Environment Variables

Create `.env.dev` and `.env.prod` files:

```bash
# backend/.env.dev
AWS_REGION=us-east-1
ENVIRONMENT=dev
STAGE=dev

# Database tables
USERS_TABLE=users-dev
PRODUCTS_TABLE=products-dev
ORDERS_TABLE=orders-dev
CARTS_TABLE=carts-dev
INVENTORY_TABLE=inventory-dev

# S3 buckets
UPLOADS_BUCKET=serverless-ecommerce-dev-uploads
PRODUCT_IMAGES_BUCKET=serverless-ecommerce-dev-product-images

# Queue/Topic ARNs
ORDERS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/ACCOUNT_ID/orders-queue-dev
ORDERS_TOPIC_ARN=arn:aws:sns:us-east-1:ACCOUNT_ID:orders-topic-dev

# Secrets
PASSWORD_SALT=your-random-salt-here
JWT_SECRET=your-jwt-secret-here
```

### 3. Deploy Infrastructure (via Terraform)

```bash
cd ../infrastructure/terraform
terraform apply -var="environment=dev"
```

This creates:
- DynamoDB tables
- SQS queues
- SNS topics
- S3 buckets
- IAM roles

### 4. Start Services Locally

```bash
cd ../../backend
serverless offline start
```

Services run on:
- Auth Service: http://localhost:3000/auth
- Product Service: http://localhost:3000/products
- Order Service: http://localhost:3000/orders
- etc.

## Service-Specific Setup

### Auth Service

```bash
cd auth-service
npm install
npm run dev

# Test
curl -X POST http://localhost:3000/auth/signup \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

### Product Service

```bash
cd product-service
npm install
npm run dev

# Test
curl http://localhost:3000/products
```

## Testing

### Run All Tests
```bash
npm run test
```

### Run Tests for Specific Service
```bash
cd auth-service
npm run test
```

### Coverage Report
```bash
npm run test:coverage
```

## Deployment

### Deploy to Dev

```bash
export AWS_PROFILE=dev-profile
npm run deploy:dev
```

### Deploy to Production

```bash
export AWS_PROFILE=prod-profile
npm run deploy:prod
```

## Monitoring & Logs

### View CloudWatch Logs

```bash
# Auth service logs
aws logs tail /aws/lambda/auth-service-dev --follow

# All Lambda logs
aws logs tail /aws/lambda --follow
```

### View Metrics

```bash
# Duration
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=auth-service-dev \
  --statistics Average,Maximum \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600
```

## Troubleshooting

### Services not starting locally

```bash
# Check if ports are in use
lsof -i :3000

# Kill existing process
kill -9 <PID>

# Try again
serverless offline start
```

### DynamoDB table not found

```bash
# Check table exists
aws dynamodb list-tables --region us-east-1

# Create if missing
aws dynamodb create-table \
  --table-name users-dev \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### Lambda timeout errors

```bash
# Increase timeout in serverless.yml
provider:
  timeout: 30  # seconds
```

### CORS errors

```bash
# Verify API Gateway CORS settings
aws apigateway get-stage \
  --rest-api-id YOUR_API_ID \
  --stage-name dev
```

## CI/CD Integration

### GitHub Actions Workflow

See `.github/workflows/backend.yml` for automated deployment.

**Triggers**:
- Push to dev branch → Deploy to dev
- Push to main branch → Deploy to prod (with approval)
- Pull requests → Run tests & lint

## Scaling Considerations

### DynamoDB Capacity

```bash
# Switch to on-demand (scales automatically)
aws dynamodb update-billing-mode \
  --table-name users-dev \
  --billing-mode PAY_PER_REQUEST
```

### Lambda Concurrency

```bash
# Set reserved concurrency
aws lambda put-function-concurrency \
  --function-name auth-service-dev \
  --reserved-concurrent-executions 100
```

### API Gateway Throttling

```bash
# Set throttle settings
aws apigateway update-stage \
  --rest-api-id YOUR_API_ID \
  --stage-name dev \
  --patch-operations \
    op=replace,path='/**/ThrottlingRateLimit',value='10000' \
    op=replace,path='/**/ThrottlingBurstLimit',value='5000'
```

## Production Checklist

- [ ] All tests passing
- [ ] Code reviewed
- [ ] Environment variables configured
- [ ] CloudWatch alarms set up
- [ ] CORS configured correctly
- [ ] Rate limiting enabled
- [ ] Logging configured
- [ ] Backups enabled
- [ ] Disaster recovery plan in place
- [ ] Load testing completed

## Useful Commands

```bash
# View all Lambda functions
aws lambda list-functions --region us-east-1

# Update function code
aws lambda update-function-code \
  --function-name auth-service-dev \
  --zip-file fileb://deployment.zip

# View function logs
aws logs tail /aws/lambda/auth-service-dev

# Monitor in real-time
aws logs tail /aws/lambda --follow

# Check DynamoDB usage
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedWriteCapacityUnits \
  --dimensions Name=TableName,Value=users-dev \
  --statistics Sum \
  --period 60 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z
```

## Documentation

- [Architecture Guide](./ARCHITECTURE.md) - System design and patterns
- [API Documentation](./API.md) - Endpoint specifications
- [Deployment Guide](./DEPLOYMENT.md) - Production deployment
- [Security Guide](./SECURITY.md) - Best practices and hardening

## Support

For issues or questions:
1. Check troubleshooting section
2. Review CloudWatch logs
3. Run tests to isolate issues
4. Check AWS service health dashboard
