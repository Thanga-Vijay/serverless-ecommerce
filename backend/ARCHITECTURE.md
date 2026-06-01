# Backend Architecture Guide - PHASE 7

## Architecture Overview

```
Frontend (React/Vite)
    ↓ HTTP/REST
API Gateway (AWS)
    ↓
Lambda Services (Microservices)
    ↓
DynamoDB / SQS / SNS / S3
```

## Service Breakdown

### 1. Auth Service
**Responsibility**: User authentication and authorization

**APIs**:
```
POST /auth/signup    - Register new user
POST /auth/login     - Authenticate user
POST /auth/logout    - Logout user
GET  /auth/profile   - Get user profile
```

**Environment Variables**:
```
USERS_TABLE=Users
PASSWORD_SALT=your-secret-salt
JWT_SECRET=your-jwt-secret
```

### 2. Product Service
**Responsibility**: Product CRUD operations and management

**APIs**:
```
GET    /products              - List all products (paginated)
GET    /products/{id}         - Get product details
POST   /products              - Create product (admin only)
PUT    /products/{id}         - Update product (admin only)
DELETE /products/{id}         - Delete product (admin only)
GET    /products/search       - Search products
```

**Environment Variables**:
```
PRODUCTS_TABLE=Products
PRODUCT_IMAGES_BUCKET=product-images
```

### 3. Cart Service
**Responsibility**: Shopping cart management

**APIs**:
```
GET    /cart                    - Get user's cart
POST   /cart/items              - Add item to cart
PUT    /cart/items/{itemId}     - Update item quantity
DELETE /cart/items/{itemId}     - Remove item from cart
DELETE /cart                    - Clear cart
```

**Environment Variables**:
```
CARTS_TABLE=Carts
```

### 4. Order Service
**Responsibility**: Order placement and management

**APIs**:
```
POST   /orders                  - Place new order
GET    /orders/{id}             - Get order details
GET    /orders/user             - List user's orders
PUT    /orders/{id}/status      - Update order status (admin)
```

**Environment Variables**:
```
ORDERS_TABLE=Orders
ORDERS_QUEUE_URL=SQS queue URL
ORDERS_TOPIC_ARN=SNS topic ARN
```

### 5. Inventory Service
**Responsibility**: Stock management and tracking

**APIs**:
```
GET    /inventory/{productId}   - Get stock level
PUT    /inventory/{productId}   - Update stock (internal use)
```

**Environment Variables**:
```
INVENTORY_TABLE=Inventory
```

### 6. Payment Service
**Responsibility**: Payment processing

**APIs**:
```
POST   /payments                - Process payment
GET    /payments/{id}           - Get payment details
```

**Environment Variables**:
```
STRIPE_API_KEY=stripe-key
STRIPE_WEBHOOK_SECRET=webhook-secret
```

### 7. Notification Service
**Responsibility**: Email and SMS notifications

**Triggered by**: SNS topics from other services

**Events**:
- User registration
- Order confirmation
- Order status updates
- Payment confirmation

**Environment Variables**:
```
SES_EMAIL_FROM=noreply@example.com
SNS_ORDERS_TOPIC=SNS topic
```

### 8. Upload Service
**Responsibility**: Generate S3 presigned URLs for file uploads

**APIs**:
```
POST   /uploads/presigned-url   - Generate upload URL
```

**Environment Variables**:
```
UPLOADS_BUCKET=bucket-name
UPLOAD_EXPIRATION=3600
```

## Layer Architecture Pattern

```
HTTP Request
    ↓
Handler (src/handlers/index.js)
    ↓ - Parse request
    ↓ - Validate input
    ↓
Service (src/services/*.service.js)
    ↓ - Business logic
    ↓ - Orchestration
    ↓
Repository (src/repositories/*.repository.js)
    ↓ - Database access
    ↓ - Query execution
    ↓
DynamoDB/AWS Service
    ↓
Database
```

## Implementation Details

### Handler Responsibilities
```javascript
// src/handlers/index.js
- Extract data from event
- Validate input
- Call service
- Format response
- Handle errors
```

### Service Responsibilities
```javascript
// src/services/*.service.js
- Business logic
- Data transformation
- Validation rules
- Service-to-service calls
- Event publishing
```

### Repository Responsibilities
```javascript
// src/repositories/*.repository.js
- DynamoDB access
- Query building
- Data marshalling
- Connection management
```

## DynamoDB Table Design

### Users Table
```
PK: id (UUID)
SK: (none)
GSI: email (for lookup)

Attributes:
- id (PK)
- email (GSI)
- firstName
- lastName
- passwordHash
- role (user/admin)
- createdAt
- updatedAt
- lastLogin
```

### Products Table
```
PK: id (UUID)
SK: (none)
GSI: categoryId (for filtering)

Attributes:
- id (PK)
- name
- description
- price
- category
- stock
- imageUrl
- sku
- createdAt
- updatedAt
```

### Orders Table
```
PK: id (UUID)
SK: (none)
GSI: userId (for user queries)
GSI: status (for filtering)

Attributes:
- id (PK)
- userId (GSI)
- items (list)
- total
- status (pending/processing/shipped/delivered)
- shippingAddress
- createdAt
- updatedAt
```

### Carts Table
```
PK: userId
SK: (none)

Attributes:
- userId (PK)
- items (list)
- subtotal
- tax
- total
- updatedAt
```

## Shared Utilities Structure

```
backend/shared/src/
├── logger.js                 # Structured logging
├── errors.js                 # Custom error classes
├── response.js               # API response formatter
├── jwt-validator.js          # JWT validation
├── auth-middleware.js        # Authentication middleware
├── validator.js              # Input validation
└── dynamodb-client.js        # DynamoDB wrapper
```

## Error Handling Pattern

```javascript
// All services throw consistent errors
throw new ValidationError('Invalid input', { field: 'email' });
throw new AuthError('Unauthorized');
throw new NotFoundError('Product');
throw new ConflictError('Email already exists');
throw new AppError('Custom error', 500, 'CODE');

// Handler catches and formats
try {
  return ApiResponse.success(data);
} catch (error) {
  return ApiResponse.error(error);
}
```

## Security Best Practices

### 1. JWT Validation
```javascript
- Extract token from Authorization header
- Validate token signature
- Check token expiration
- Verify issuer (Cognito)
- Extract user claims
```

### 2. Input Validation
```javascript
- Validate all request inputs
- Sanitize strings
- Type checking
- Range validation
```

### 3. IAM Permissions
```
Lambda Execution Role:
- dynamodb:GetItem
- dynamodb:PutItem
- dynamodb:UpdateItem
- dynamodb:DeleteItem
- dynamodb:Query
- s3:GetObject
- s3:PutObject
- sqs:SendMessage
- sns:Publish
- ses:SendEmail (notification service)
```

### 4. Environment Variables
```
- Never commit secrets
- Use AWS Secrets Manager for sensitive data
- Different values per environment
- Rotate keys regularly
```

## Deployment Strategy

### Local Development
```bash
# Start services locally
npm install
npm run dev

# Runs on localhost with serverless-offline
```

### Staging/Dev Deployment
```bash
# Deploy to AWS
npm run deploy:dev

# Sets environment to dev
# Deploys to separate tables/queues
```

### Production Deployment
```bash
# Production deployment
npm run deploy:prod

# Requires approval
# Separate tables/queues
# Additional monitoring
```

## Testing Strategy

### Unit Tests
```javascript
// Test services in isolation
jest.mock('../repositories/auth.repository');
test('signup should create user');
test('login should validate password');
```

### Integration Tests
```javascript
// Test handler with mocked AWS
test('POST /auth/signup should create user');
test('GET /products should return products');
```

### Local Testing
```bash
# Run locally with serverless-offline
serverless offline start

# Test with curl/Postman
curl -X POST http://localhost:3000/auth/signup \
  -H 'Content-Type: application/json' \
  -d '{...}'
```

## Monitoring & Logging

### Structured Logging
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "service": "auth-service",
  "message": "User login successful",
  "userId": "user-123",
  "requestId": "req-456"
}
```

### CloudWatch Metrics
- Lambda duration
- Lambda errors
- DynamoDB throttling
- API Gateway latency
- Error rates

### Alarms
- High error rate
- Slow response times
- DynamoDB throttles
- Lambda timeout

## Scaling Considerations

### DynamoDB Scaling
- Use on-demand pricing for variable load
- Or provisioned with auto-scaling
- Global secondary indexes for queries
- Consider partition key design

### Lambda Concurrency
- Set reserved concurrency
- Configure memory (128MB-10GB)
- Optimize cold start time
- Use layers for shared code

### API Gateway
- Caching enabled
- Throttling configured
- CORS properly set
- Request/response logging

## CI/CD Pipeline

### Build
```bash
npm install
npm run lint
npm run test
npm run build
```

### Deploy Dev
```bash
# Auto-deploy on merge to dev
npm run deploy:dev
```

### Deploy Prod
```bash
# Requires approval
# Manual trigger
npm run deploy:prod
```

## Next Steps

1. Install dependencies in each service
2. Configure DynamoDB tables
3. Set up IAM roles
4. Deploy services to AWS
5. Set up API Gateway routes
6. Configure CloudWatch alarms
7. Create automated tests
8. Set up monitoring

## File Structure Summary

```
backend/
├── shared/
│   └── src/
│       ├── logger.js
│       ├── errors.js
│       ├── response.js
│       ├── jwt-validator.js
│       ├── auth-middleware.js
│       ├── validator.js
│       └── dynamodb-client.js
│
├── auth-service/
│   ├── src/
│   │   ├── handlers/
│   │   │   └── index.js
│   │   ├── services/
│   │   │   └── auth.service.js
│   │   ├── repositories/
│   │   │   └── auth.repository.js
│   │   └── validations/
│   ├── tests/
│   ├── package.json
│   └── serverless.yml
│
├── product-service/
│   ├── src/
│   │   ├── handlers/
│   │   ├── services/
│   │   └── repositories/
│   └── ...
│
├── order-service/
├── upload-service/
├── notification-service/
├── payment-service/
├── inventory-service/
└── cart-service/
```

---

**For detailed implementation of each service, see the individual service READMEs.**
