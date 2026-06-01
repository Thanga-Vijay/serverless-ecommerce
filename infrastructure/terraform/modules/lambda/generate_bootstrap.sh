#!/bin/bash
# Generate bootstrap.zip for Lambda placeholder code
# This script creates a minimal handler that will be replaced by CI/CD

set -e

# Configuration
BOOTSTRAP_DIR="${1:-.}/bootstrap-handler"
OUTPUT_ZIP="${2:-.}/bootstrap.zip"

# Create bootstrap directory
mkdir -p "$BOOTSTRAP_DIR"

# Create Node.js bootstrap handler
cat > "$BOOTSTRAP_DIR/index.js" << 'EOF'
/**
 * Bootstrap Lambda Handler
 * This is a placeholder deployed by Terraform.
 * Actual code is deployed by GitHub Actions via aws lambda update-function-code.
 */

exports.handler = async (event, context) => {
  console.log(JSON.stringify({
    message: "Lambda function initializing",
    status: "bootstrap",
    timestamp: new Date().toISOString(),
    functionName: context.functionName,
    functionVersion: context.functionVersion,
    awsRequestId: context.awsRequestId
  }));

  return {
    statusCode: 503,
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      error: "Service Unavailable",
      message: "Lambda function is initializing. Application code deployment is pending.",
      requestId: context.awsRequestId,
      timestamp: new Date().toISOString()
    })
  };
};
EOF

# Create Python bootstrap handler for alternative runtimes
cat > "$BOOTSTRAP_DIR/lambda_function.py" << 'EOF'
"""
Bootstrap Lambda Handler (Python)
This is a placeholder deployed by Terraform.
Actual code is deployed by GitHub Actions via aws lambda update-function-code.
"""

import json
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(json.dumps({
        "message": "Lambda function initializing",
        "status": "bootstrap",
        "timestamp": datetime.utcnow().isoformat(),
        "function_name": context.function_name,
        "function_version": context.function_version,
        "aws_request_id": context.aws_request_id
    }))

    return {
        "statusCode": 503,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "error": "Service Unavailable",
            "message": "Lambda function is initializing. Application code deployment is pending.",
            "requestId": context.aws_request_id,
            "timestamp": datetime.utcnow().isoformat()
        })
    }
EOF

# Create package.json for Node.js compatibility
cat > "$BOOTSTRAP_DIR/package.json" << 'EOF'
{
  "name": "lambda-bootstrap",
  "version": "1.0.0",
  "description": "Bootstrap handler for Lambda deployment",
  "main": "index.js",
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# Create README for bootstrap archive
cat > "$BOOTSTRAP_DIR/README.md" << 'EOF'
# Lambda Bootstrap Handler

This is a placeholder handler deployed by Terraform as part of the infrastructure setup.

## Purpose

- Establishes Lambda function infrastructure (IAM, logs, permissions)
- Allows Terraform and CI/CD to work independently
- Provides graceful degradation during deployment

## Replacement

This code will be replaced by GitHub Actions via:

```bash
aws lambda update-function-code \
  --function-name <function-name> \
  --zip-file fileb://dist/<service>.zip
```

## Response During Bootstrap Phase

```json
{
  "statusCode": 503,
  "body": {
    "error": "Service Unavailable",
    "message": "Lambda function is initializing. Application code deployment is pending."
  }
}
```
EOF

# Create the ZIP archive
cd "$BOOTSTRAP_DIR"
zip -r "../bootstrap.zip" . -x ".git*" "*.md"
cd - > /dev/null

# Display results
echo "✓ Bootstrap ZIP created: $OUTPUT_ZIP"
echo "  Files included:"
unzip -l "$OUTPUT_ZIP" | tail -n +4 | head -n -2 | awk '{print "    " $4}'

# Output file hash for Terraform source_code_hash
echo ""
echo "Add this to your Terraform variables:"
HASH=$(openssl dgst -sha256 -binary "$OUTPUT_ZIP" | openssl enc -base64)
echo "bootstrap_source_code_hash = \"$HASH\""
