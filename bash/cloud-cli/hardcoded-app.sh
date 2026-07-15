#!/usr/bin/env bash
# Sample cloud CLI app - BEFORE.
# AWS credentials are hardcoded directly in the script. Compare with
# vault-app.sh.
set -euo pipefail

AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"                            # <-- hardcoded, bad
AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"    # <-- hardcoded, bad

echo "Listing S3 buckets using AWS credentials..."
echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
# AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" aws s3 ls
echo "S3 bucket list simulated successfully."
