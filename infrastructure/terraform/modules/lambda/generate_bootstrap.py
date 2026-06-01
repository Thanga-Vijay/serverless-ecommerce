#!/usr/bin/env python3
"""
Generate bootstrap.zip for Lambda deployment
Run: python3 modules/lambda/generate_bootstrap.py
"""

import os
import zipfile
import tempfile
import hashlib
import base64
from pathlib import Path


def create_bootstrap_zip(output_path: str = "bootstrap.zip") -> str:
    """Create bootstrap.zip with placeholder Lambda handlers."""

    # Create temporary directory
    temp_dir = tempfile.mkdtemp()
    bootstrap_dir = Path(temp_dir) / "bootstrap-handler"
    bootstrap_dir.mkdir(parents=True, exist_ok=True)

    # Node.js Handler
    nodejs_handler = '''/**
 * Bootstrap Lambda Handler
 * Placeholder deployed by Terraform. Actual code deployed by GitHub Actions.
 */
exports.handler = async (event, context) => {
  console.log(JSON.stringify({
    message: "Lambda function initializing",
    status: "bootstrap",
    timestamp: new Date().toISOString(),
    functionName: context.functionName,
    awsRequestId: context.awsRequestId
  }));

  return {
    statusCode: 503,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      error: "Service Unavailable",
      message: "Lambda function is initializing. Code deployment pending.",
      requestId: context.awsRequestId,
      timestamp: new Date().toISOString()
    })
  };
};
'''

    # Python Handler
    python_handler = '''import json
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
        "aws_request_id": context.aws_request_id
    }))

    return {
        "statusCode": 503,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({
            "error": "Service Unavailable",
            "message": "Lambda function is initializing. Code deployment pending.",
            "requestId": context.aws_request_id,
            "timestamp": datetime.utcnow().isoformat()
        })
    }
'''

    # package.json for Node.js
    package_json = '''{
  "name": "lambda-bootstrap",
  "version": "1.0.0",
  "description": "Bootstrap handler for Lambda deployment",
  "main": "index.js",
  "engines": {
    "node": ">=18.0.0"
  }
}
'''

    # README
    readme = '''# Lambda Bootstrap Handler

This is a placeholder handler deployed by Terraform as part of infrastructure setup.

## Purpose

- Establishes Lambda function infrastructure (IAM, logs, permissions)
- Allows Terraform and CI/CD to work independently
- Provides graceful degradation during deployment

## Replacement

This code will be replaced by GitHub Actions via:

```bash
aws lambda update-function-code \\
  --function-name <function-name> \\
  --zip-file fileb://dist/<service>.zip
```

## Response During Bootstrap Phase

```json
{
  "statusCode": 503,
  "body": {
    "error": "Service Unavailable",
    "message": "Lambda function is initializing. Code deployment pending."
  }
}
```
'''

    # Write files
    (bootstrap_dir / "index.js").write_text(nodejs_handler)
    (bootstrap_dir / "lambda_function.py").write_text(python_handler)
    (bootstrap_dir / "package.json").write_text(package_json)
    (bootstrap_dir / "README.md").write_text(readme)

    # Create ZIP
    output_zip = Path(output_path).resolve()
    output_zip.parent.mkdir(parents=True, exist_ok=True)

    with zipfile.ZipFile(output_zip, 'w', zipfile.ZIP_DEFLATED) as zf:
        for file_path in bootstrap_dir.rglob('*'):
            if file_path.is_file():
                arcname = file_path.relative_to(bootstrap_dir)
                zf.write(file_path, arcname)

    # Verify and display
    print(f"✓ Bootstrap ZIP created: {output_zip}")
    print("\nContents:")
    with zipfile.ZipFile(output_zip, 'r') as zf:
        for info in zf.filelist:
            print(f"  {info.filename} ({info.file_size} bytes)")

    # Calculate hash
    with open(output_zip, 'rb') as f:
        content = f.read()
        hash_val = base64.b64encode(hashlib.sha256(content).digest()).decode()
        size_kb = len(content) / 1024

    print(f"\nFile size: {size_kb:.2f} KB")
    print(f"\nAdd to your Terraform variables.tf or tfvars:")
    print(f'bootstrap_source_code_hash = "{hash_val}"')

    # Cleanup
    import shutil
    shutil.rmtree(temp_dir)

    return str(output_zip)


if __name__ == "__main__":
    import sys

    # Get output path from args or use default
    output_path = sys.argv[1] if len(sys.argv) > 1 else "bootstrap.zip"

    try:
        zip_path = create_bootstrap_zip(output_path)
        print(f"\n✓ Success! Bootstrap ZIP ready at: {zip_path}")
        sys.exit(0)
    except Exception as e:
        print(f"✗ Error: {e}", file=sys.stderr)
        sys.exit(1)
