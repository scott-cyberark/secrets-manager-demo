#!/usr/bin/env bash
# Sample cloud app - DYNAMIC secrets version.
#
# Compare with ../bash/cloud-cli/vault-app.sh, which fetches *static* AWS
# keys from the vault. Here there is no stored AWS credential at all:
# every run asks Idira Secrets Manager for the dynamic secret, and Idira
# mints fresh STS credentials (TTL 15 min) scoped by an inline policy.
# There is nothing to rotate and nothing long-lived to steal.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../bash/cloud-cli/idira-client.sh"

# Reuse the cloud-cli workload's identity (gitignored .env)
if [ -f "${SCRIPT_DIR}/../bash/cloud-cli/.env" ]; then
  set -a; source "${SCRIPT_DIR}/../bash/cloud-cli/.env"; set +a
fi

DYNAMIC_SECRET_PATH="data/dynamic/demo-s3-reader"

echo "Authenticating to Idira as the cloud-cli workload..."
TOKEN="$(idira_authenticate)"

echo "Fetching dynamic secret '${DYNAMIC_SECRET_PATH}' (mints fresh STS credentials)..."
RESPONSE="$(idira_get_secret "$DYNAMIC_SECRET_PATH" "$TOKEN")"

CREDS="$(echo "$RESPONSE" | jq 'first(.. | objects | select(has("access_key_id")))')"
AWS_ACCESS_KEY_ID="$(echo "$CREDS" | jq -r '.access_key_id')"
AWS_SECRET_ACCESS_KEY="$(echo "$CREDS" | jq -r '.secret_access_key')"
AWS_SESSION_TOKEN="$(echo "$CREDS" | jq -r '.session_token')"

echo "Received ephemeral credentials (access key ${AWS_ACCESS_KEY_ID:0:8}..., expires soon)."
echo
echo "Using them against AWS:"
AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN" \
  aws sts get-caller-identity

AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN" \
  aws s3 ls

echo
echo "Done - these credentials self-destruct in ~15 minutes."
