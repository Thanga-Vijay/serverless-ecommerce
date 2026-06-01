# Lambda Bootstrap Strategy

Terraform creates Lambda infrastructure and deploys a minimal placeholder ZIP.
GitHub Actions owns application package deployment after that first apply.

## Bootstrap ZIP

The module uses the `archive_file` data source to package:

```text
bootstrap/
└── index.js
```

The generated `bootstrap.zip` is written inside the module directory during
Terraform execution. It does not need to be committed.

## Deployment Flow

1. Terraform creates IAM roles, log groups, Lambda functions, permissions, and
   SQS event source mappings.
2. Each function initially returns HTTP `503` from `bootstrap/index.js`.
3. GitHub Actions packages each backend service.
4. GitHub Actions deploys code without changing infrastructure:

```bash
aws lambda update-function-code \
  --function-name serverless-ecommerce-prod-auth-service \
  --zip-file fileb://dist/auth-service.zip
```

## Lifecycle Ownership

The Lambda resource ignores code-package drift:

```hcl
lifecycle {
  ignore_changes = [
    filename,
    source_code_hash,
    last_modified,
  ]
}
```

Terraform continues to manage runtime, handler, memory, timeout, environment
variables, IAM role assignment, tags, tracing, permissions, and log retention.
