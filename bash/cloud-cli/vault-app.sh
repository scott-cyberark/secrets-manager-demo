#!/usr/bin/env bash
# Sample cloud CLI app - AFTER.
# Same app as hardcoded-app.sh, but AWS credentials are pulled dynamically
# from Idira Secrets Manager at runtime instead of being embedded in the
# script.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/idira-client.sh"

# Conjur-native demo branch. (data/vault/... is reserved for the Vault
# Synchronizer, which mirrors real Privilege Cloud safes - see the
# .github/workflows/secrets.yml sample for that convention.)
SECRET_PATH_ACCESS_KEY="data/demo-apps/cloud-app/aws_access_key_id"
SECRET_PATH_SECRET_KEY="data/demo-apps/cloud-app/aws_secret_access_key"

TOKEN="$(idira_authenticate)"

AWS_ACCESS_KEY_ID="$(idira_get_secret "$SECRET_PATH_ACCESS_KEY" "$TOKEN")"
AWS_SECRET_ACCESS_KEY="$(idira_get_secret "$SECRET_PATH_SECRET_KEY" "$TOKEN")"

echo "Listing S3 buckets using AWS credentials fetched from Idira Secrets Manager..."
echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
# AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" aws s3 ls
echo "S3 bucket list simulated successfully."
