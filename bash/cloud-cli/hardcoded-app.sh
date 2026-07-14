#!/usr/bin/env bash
# Sample cloud CLI app - BEFORE.
# AWS credentials are hardcoded directly in the script. Compare with
# vault-app.sh.
set -euo pipefail

AWS_ACCESS_KEY_ID="REPLACE_WITH_YOUR_AWS_ACCESS_KEY_ID"         # <-- hardcoded, bad
AWS_SECRET_ACCESS_KEY="REPLACE_WITH_YOUR_AWS_SECRET_ACCESS_KEY" # <-- hardcoded, bad

echo "Listing S3 buckets using AWS credentials..."
echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
# AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" aws s3 ls
echo "S3 bucket list simulated successfully."
