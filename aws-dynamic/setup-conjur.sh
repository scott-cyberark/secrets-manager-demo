#!/usr/bin/env bash
# Creates the dynamic secret resource in Idira Secrets Manager and grants
# the cloud-cli workload access. Prerequisites: 'conjur login' done and
# setup-aws.sh already run (the issuer must exist).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "==> Loading the dynamic secret definition (data/dynamic/demo-s3-reader)..."
conjur policy load -b data/dynamic -f policy/aws-dynamic-secret.yml

echo "==> Granting the cloud-cli workload read/execute..."
conjur policy load -b data/dynamic -f policy/grant-workload.yml

echo
echo "Done. Run the sample with:  ./vault-app.sh  (uses ../bash/cloud-cli/.env)"
