# serverless-ecommerce in dev branch
use this folder structure "/Users/ops/Documents/practice/serverless-ecommerce" use this bcuket for state file"tf-state-bucket-sls"

create folder structure like 

serverless-ecommerce/
│
├── .github/
│   └── workflows/
│       ├── terraform.yml
│       ├── frontend.yml
│       └── backend.yml
│
├── infrastructure/
│   └── terraform/
│
├── frontend/
│
├── backend/
│



and 

infrastructure/
└── terraform/
    │    
    ├── common/
    │   ├── main.tf
    │   ├── provider.tf
    │   ├── backend.tf
    │   ├── dev.tfvars
    │   ├── stg.tfvars
    │   ├── prod.tfvars
    │   ├── variables.tf
    │   ├── locals.tf
    │   └── outputs.tf
    ├── modules/
    │   ├── lambda/
    │   ├── dynamodb/
    │   ├── apigateway/
    │   ├── cognito/
    │   ├── s3/
    │   └── iam/
    │


then. 

Create enterprise-grade Terraform folder structure for a serverless ecommerce platform using:
- Lambda
- API Gateway
- DynamoDB
- Cognito
- S3
- CloudFront
- SQS
- SNS
- Step Functions

Requirements:
- reusable modules
- dev/prod tfvars
- outputs
- variables
- naming conventions
- terraform best practices


and 

Create production-grade GitHub Actions workflow terraform.yml for Terraform deployment.

Requirements:
- terraform fmt
- terraform validate
- terraform plan
- terraform apply
- use GitHub OIDC authentication
- separate dev/prod deployment
- use tfsec and tflint
- reusable environment variables