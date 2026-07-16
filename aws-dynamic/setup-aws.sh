#!/usr/bin/env bash
# Creates the AWS IAM identity that backs the Idira dynamic-secret issuer,
# then creates the issuer — piping the access key directly from AWS to
# Idira so it is never printed or stored on disk.
#
# Prerequisites: 'aws configure' done (admin-ish sandbox creds) and
# 'conjur login' done.
set -euo pipefail

IAM_USER="idira-dynamic-issuer-demo"
ISSUER_ID="aws-demo-issuer"

echo "==> Creating IAM user '${IAM_USER}' (idempotent)..."
aws iam create-user --user-name "$IAM_USER" 2>/dev/null || echo "    (user already exists)"

echo "==> Attaching least-privilege inline policy (GetFederationToken + s3:ListAllMyBuckets)..."
aws iam put-user-policy --user-name "$IAM_USER" --policy-name idira-issuer-demo \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      { "Effect": "Allow", "Action": "sts:GetFederationToken", "Resource": "*" },
      { "Effect": "Allow", "Action": "s3:ListAllMyBuckets",   "Resource": "*" }
    ]
  }'

echo "==> Removing any existing access keys for the user (idempotent re-runs)..."
for key in $(aws iam list-access-keys --user-name "$IAM_USER" \
  --query 'AccessKeyMetadata[].AccessKeyId' --output text); do
  aws iam delete-access-key --user-name "$IAM_USER" --access-key-id "$key"
done

echo "==> Creating vault variables to hold the issuer's IAM key..."
cd "$(dirname "${BASH_SOURCE[0]}")"
conjur policy load -b data/demo-apps -f policy/issuer-secrets.yml >/dev/null

echo "==> Creating an access key and storing it in the vault (key is not displayed)..."
KEY_JSON=$(aws iam create-access-key --user-name "$IAM_USER" --output json)
conjur variable set -i data/demo-apps/aws-issuer/access-key-id \
  -v "$(echo "$KEY_JSON" | jq -r '.AccessKey.AccessKeyId')" >/dev/null
conjur variable set -i data/demo-apps/aws-issuer/secret-access-key \
  -v "$(echo "$KEY_JSON" | jq -r '.AccessKey.SecretAccessKey')" >/dev/null
unset KEY_JSON

echo "==> Registering the issuer (references the vaulted key by secret ID)..."
conjur issuer create --id "$ISSUER_ID" --max-ttl 3600 --type aws --data '{
  "access_key_id_secret_ref":     {"id": "data/demo-apps/aws-issuer/access-key-id"},
  "secret_access_key_secret_ref": {"id": "data/demo-apps/aws-issuer/secret-access-key"}
}' >/dev/null

echo
echo "Issuer '${ISSUER_ID}' created. Next: ./setup-conjur.sh"
