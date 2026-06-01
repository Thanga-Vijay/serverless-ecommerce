# VITE_API_URL Configuration Guide

## What is VITE_API_URL?

`VITE_API_URL` is the frontend environment variable that points to your backend API endpoint. It's used to make HTTP requests from React to your AWS Lambda/API Gateway backend.

## Configuration by Environment

### Development (`frontend/.env.development`)
```
VITE_API_URL=http://localhost:8000
```

**Usage**:
- Local development
- Running backend locally with `serverless offline`
- Testing API integration locally

**How to run**:
```bash
# Terminal 1: Start backend
cd backend
npm install
serverless offline start  # Runs on localhost:3000

# Terminal 2: Update frontend env and start
cd frontend
echo 'VITE_API_URL=http://localhost:3000' > .env.development
npm run dev  # Runs on localhost:5173
```

### Production (`frontend/.env.production`)
```
VITE_API_URL=https://api.yourdomain.com
```

**Options**:

#### Option 1: API Gateway Direct URL
```
VITE_API_URL=https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod
```

**Pros**: Direct access, simple
**Cons**: URL changes on redeployment, not user-friendly

#### Option 2: Custom Domain (Recommended)
```
VITE_API_URL=https://api.yourdomain.com
```

**Setup**:
```bash
# In API Gateway console:
# 1. Custom domain names
# 2. Create mapping: api.yourdomain.com → API Gateway
# 3. Update Route53/DNS records
```

#### Option 3: CloudFront + API Gateway
```
VITE_API_URL=https://cdn.yourdomain.com/api
```

**Setup**:
```bash
# CloudFront distribution
# Origin: API Gateway
# Path: /api/* → API Gateway
```

## How to Find Your API Gateway URL

### After Terraform Deployment
```bash
cd infrastructure/terraform
terraform output api_gateway_endpoint

# Output:
# https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod
```

### In AWS Console
```
API Gateway → APIs → Your API → Stages → prod → Invoke URL
```

### Using AWS CLI
```bash
aws apigateway get-stage \
  --rest-api-id YOUR_API_ID \
  --stage-name prod \
  --query 'invokeUrl'
```

## Using VITE_API_URL in Code

### In React Components
```javascript
// Access the API URL
const API_URL = import.meta.env.VITE_API_URL;

// Make API calls
const response = await fetch(`${API_URL}/products`, {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

### In Axios Instance (Recommended)
```javascript
// src/api/axios.js
import axios from 'axios';

const axiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 10000
});

// Usage
axiosInstance.get('/products');
axiosInstance.post('/auth/login', { email, password });
```

### In API Modules
```javascript
// src/api/modules/product.js
import axiosInstance from '../axios';

export const productAPI = {
  getProducts: async () => {
    const response = await axiosInstance.get('/products');
    return response.data;
  }
};
```

## Environment Variable Priority

### Build Time (Vite)
```
1. .env.{mode}.local    (git-ignored)
2. .env.{mode}          (version controlled)
3. .env.local           (git-ignored)
4. .env                 (version controlled)
```

### At Runtime
- Baked into the build output
- Cannot be changed without rebuild
- Must rebuild frontend for each environment

## Complete Environment Setup

### Local Development
```bash
# frontend/.env.development
VITE_API_URL=http://localhost:3000
VITE_COGNITO_REGION=us-east-1
VITE_COGNITO_USER_POOL_ID=us-east-1_zlDq6Mcuc
VITE_COGNITO_CLIENT_ID=4ktrdja9h5ruhtdkrq0idlufr4
VITE_S3_BUCKET=serverless-ecommerce-dev-product-images
VITE_S3_REGION=us-east-1
```

### Staging/Development AWS
```bash
# frontend/.env.development.aws
VITE_API_URL=https://api-dev.yourdomain.com
VITE_COGNITO_REGION=us-east-1
VITE_COGNITO_USER_POOL_ID=us-east-1_devPoolId
VITE_COGNITO_CLIENT_ID=dev-client-id
VITE_S3_BUCKET=serverless-ecommerce-dev-images
VITE_S3_REGION=us-east-1
```

### Production
```bash
# frontend/.env.production
VITE_API_URL=https://api.yourdomain.com
VITE_COGNITO_REGION=ap-south-1
VITE_COGNITO_USER_POOL_ID=ap-south-1_prodPoolId
VITE_COGNITO_CLIENT_ID=prod-client-id
VITE_S3_BUCKET=serverless-ecommerce-prod-images
VITE_S3_REGION=us-east-1
```

## CORS Configuration

### API Gateway CORS Settings
```javascript
// API Gateway must allow frontend origin
Allowed origins: 
  - http://localhost:5173 (dev)
  - https://yourdomain.com (prod)
  - https://www.yourdomain.com (prod)

Allowed headers:
  - Content-Type
  - Authorization
  - X-Amz-Date
  - X-Api-Key
```

### Lambda Handler CORS Headers
```javascript
return {
  statusCode: 200,
  headers: {
    'Access-Control-Allow-Origin': '*', // Or specific domain
    'Access-Control-Allow-Headers': 'Content-Type,Authorization'
  },
  body: JSON.stringify({ ... })
};
```

## Testing API Connectivity

### Local Development
```bash
# Test API availability
curl http://localhost:3000/products

# Test with token
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/auth/profile
```

### Production
```bash
# Test API
curl https://api.yourdomain.com/products

# Check CORS
curl -i -X OPTIONS https://api.yourdomain.com/products \
  -H "Origin: https://yourdomain.com"
```

### From Browser Console
```javascript
// Check what API URL is being used
console.log(import.meta.env.VITE_API_URL);

// Test fetch
fetch(import.meta.env.VITE_API_URL + '/products')
  .then(r => r.json())
  .then(d => console.log(d));
```

## Deployment Workflow

### Local to AWS Dev
```bash
# 1. Deploy backend
cd backend
npm install
npm run deploy:dev

# Get API Gateway URL
terraform output api_gateway_endpoint

# 2. Update frontend env
cd ../frontend
echo 'VITE_API_URL=https://api-dev.yourdomain.com' > .env.development

# 3. Build and deploy
npm run build
npm run deploy:dev
```

### Local to AWS Prod
```bash
# 1. Update frontend env for production
echo 'VITE_API_URL=https://api.yourdomain.com' > .env.production

# 2. Build for production
npm run build

# 3. Deploy to S3
npm run deploy:prod

# 4. Invalidate CloudFront
aws cloudfront create-invalidation \
  --distribution-id YOUR_DIST_ID \
  --paths "/*"
```

## Troubleshooting

### Issue: API requests return CORS error
**Solution**:
```
1. Check API Gateway CORS settings
2. Verify origin is in allowed list
3. Check request headers match allowed
4. Check Lambda response headers
```

### Issue: 404 errors on API calls
**Solution**:
```
1. Verify VITE_API_URL is correct
2. Check API Gateway routes exist
3. Verify Lambda functions deployed
4. Check API Gateway stage name
```

### Issue: VITE_API_URL is not being used
**Solution**:
```
1. Rebuild frontend (values are baked in)
2. Check .env file is in correct location
3. Restart dev server
4. Use correct VITE_ prefix
```

### Issue: Authentication fails after API URL change
**Solution**:
```
1. Clear browser cache/cookies
2. Check token format is correct
3. Verify JWT validation in Lambda
4. Check token expiration
```

## Security Considerations

### DO
- ✓ Use HTTPS in production
- ✓ Set specific CORS origins
- ✓ Validate all inputs server-side
- ✓ Use short-lived tokens
- ✓ Implement rate limiting

### DON'T
- ✗ Expose secrets in .env files (use .gitignore)
- ✗ Use wildcard CORS origins in production
- ✗ Log sensitive data
- ✗ Commit .env.local files
- ✗ Hardcode API URLs

## Migration Guide

### Changing API URL After Deployment

**Step 1**: Update environment file
```bash
VITE_API_URL=https://new-api.yourdomain.com
```

**Step 2**: Rebuild frontend
```bash
npm run build
```

**Step 3**: Deploy new build
```bash
npm run deploy:prod
```

**Step 4**: Invalidate CDN cache
```bash
aws cloudfront create-invalidation \
  --distribution-id DIST_ID \
  --paths "/*"
```

## References

- [Vite Env Variables](https://vitejs.dev/guide/env-and-mode)
- [AWS API Gateway](https://docs.aws.amazon.com/apigateway/)
- [API Gateway CORS](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html)
- [Axios Configuration](https://axios-http.com/docs/config_defaults)
