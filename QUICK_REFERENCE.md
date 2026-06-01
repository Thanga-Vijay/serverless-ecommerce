# Quick Reference Guide

## 🚀 Quick Start

```bash
# 1. Install everything
./setup.sh

# 2. Frontend
cd frontend && npm run dev      # http://localhost:5173

# 3. Backend (in new terminal)
cd backend && serverless offline start    # http://localhost:3000

# 4. Tests
npm run test

# 5. Build
npm run build
```

---

## 📁 Key Files

| File | Purpose | Location |
|------|---------|----------|
| **Frontend Entry** | Main React app | `frontend/src/App.jsx` |
| **Redux Store** | State management | `frontend/src/redux/store.js` |
| **API Layer** | Axios config & calls | `frontend/src/api/axios.js` |
| **Auth Guard** | Route protection | `frontend/src/routes/ProtectedRoute.jsx` |
| **Backend Shared** | Reusable utilities | `backend/shared/src/` |
| **Auth Service** | User authentication | `backend/auth-service/src/` |
| **Architecture** | System design | `backend/ARCHITECTURE.md` |
| **Setup Guide** | Deployment help | `backend/SETUP.md` |
| **Env Config** | Environment guide | `API_URL_SETUP.md` |

---

## 🔑 Environment Variables

### Frontend (.env.development)
```
VITE_API_URL=http://localhost:8000
VITE_COGNITO_DOMAIN=https://your-domain.auth.region.amazoncognito.com
VITE_COGNITO_CLIENT_ID=your-client-id
VITE_COGNITO_REDIRECT_URI=http://localhost:5173/auth/callback
VITE_S3_BUCKET=your-bucket-dev
VITE_REGION=us-east-1
```

### Backend (.env.dev)
```
AWS_REGION=us-east-1
STAGE=dev
USERS_TABLE=users-dev
PRODUCTS_TABLE=products-dev
ORDERS_TABLE=orders-dev
CARTS_TABLE=carts-dev
PASSWORD_SALT=salt-here
JWT_SECRET=secret-here
```

---

## 🌐 API Endpoints

### Auth Service
```
POST   /auth/signup          Create new user
POST   /auth/login           User login
GET    /auth/profile         Get user profile
POST   /auth/logout          Logout user
```

### Product Service
```
GET    /products             List all products
GET    /products/{id}        Get product details
POST   /products             Create product
PUT    /products/{id}        Update product
DELETE /products/{id}        Delete product
```

### Order Service
```
POST   /orders               Create order
GET    /orders/{id}          Get order details
GET    /orders/user/{id}     Get user orders
```

### Cart Service
```
GET    /cart                 Get cart
POST   /cart/items           Add to cart
DELETE /cart/items/{id}      Remove from cart
```

### Upload Service
```
POST   /uploads/presigned-url   Get upload URL
```

---

## 📊 DynamoDB Tables

| Table | Partition Key | Sort Key | Purpose |
|-------|---|---|---|
| users | id | - | User accounts |
| products | id | - | Product catalog |
| orders | id | createdAt | Order history |
| carts | userId | productId | Shopping carts |
| inventory | productId | - | Stock levels |
| payments | id | createdAt | Payment records |
| notifications | id | createdAt | Email queue |
| uploads | id | createdAt | File uploads |

---

## 🧪 Testing

```bash
# Run all tests
npm run test

# Watch mode
npm run test:watch

# Coverage report
npm run test:coverage

# Specific service
cd backend/auth-service && npm run test
```

---

## 🔍 Common Tasks

### Add New Component
```bash
# Frontend
cd frontend/src/components
# Create YourComponent.jsx

# Add to App.jsx routes or header
```

### Add New Service
```bash
# Use template: backend/product-service/
cp -r backend/product-service backend/your-service
# Edit package.json, handlers, services, repositories
```

### Add New DynamoDB Table
```bash
# Edit: infrastructure/terraform/modules/dynamodb/tables.tf
# Add new resource block
# Run: terraform apply
```

### Deploy Lambda
```bash
cd backend
npm run deploy:dev      # Deploy to dev
npm run deploy:prod     # Deploy to production
```

---

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Find process
lsof -i :3000

# Kill it
kill -9 <PID>
```

### DynamoDB Not Found
```bash
# Check tables exist
aws dynamodb list-tables --region us-east-1

# Create table
aws dynamodb create-table \
  --table-name users-dev \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### CORS Issues
```bash
# Check API Gateway CORS
aws apigateway get-stage --rest-api-id <ID> --stage-name dev

# Frontend should have correct VITE_API_URL
```

### JWT Validation Fails
```bash
# Check Cognito keys are valid
# Check token format: Authorization: Bearer <token>
# Verify token not expired
```

---

## 📈 Monitoring

### View Logs
```bash
# Frontend logs
aws logs tail /aws/s3/frontend-dev

# Lambda logs
aws logs tail /aws/lambda/auth-service-dev --follow

# All logs
aws logs tail /aws/lambda --follow
```

### Check Metrics
```bash
# Lambda duration
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=auth-service-dev \
  --statistics Average,Maximum \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600
```

---

## 🔐 Security Checklist

- [ ] Environment variables set (no secrets in code)
- [ ] JWT validation enabled
- [ ] CORS configured
- [ ] Input validation active
- [ ] Error handling without exposing details
- [ ] IAM roles least privilege
- [ ] S3 buckets not public
- [ ] DynamoDB encryption enabled
- [ ] CloudTrail logging enabled
- [ ] API Gateway logging enabled

---

## 📚 Documentation Links

- **Full Architecture**: `backend/ARCHITECTURE.md`
- **Setup Instructions**: `backend/SETUP.md`
- **Environment Config**: `API_URL_SETUP.md`
- **Project Status**: `PROJECT_STATUS.md`
- **Terraform Docs**: `infrastructure/terraform/README.md`

---

## 🎯 Common Commands

```bash
# Frontend
npm run dev              # Dev server
npm run build           # Production build
npm run test            # Run tests
npm run lint            # Check code style

# Backend
npm install             # Install deps
serverless offline      # Local development
npm run test            # Run tests
npm run deploy:dev      # Deploy to dev
npm run deploy:prod     # Deploy to prod

# Terraform
terraform plan          # See changes
terraform apply         # Apply changes
terraform destroy       # Destroy resources
terraform output        # Show outputs

# AWS CLI
aws s3 ls               # List buckets
aws lambda list-functions  # List lambdas
aws dynamodb list-tables    # List tables
aws logs tail /aws/lambda   # View logs
```

---

## 🚦 Status Indicators

✅ = Complete & Production Ready
📋 = Scaffolded & Ready for Implementation
⚠️ = Needs Configuration
❌ = Not Started

---

**Last Updated**: January 2024
**Quick Reference Version**: 1.0
**Total Services**: 8 (1 complete, 7 scaffolded)
**Total Components**: 70+
**Lines of Code**: 10,000+
