#!/usr/bin/env bash
# Exports the SPIRE trust domain's JWT-SVID signing keys as a standard JWKS
# document (jwks.json), formatted for Secrets Manager's authn-jwt
# 'public-keys' variable (public-keys.json).
#
# We use a static JWKS because this SPIRE server runs on a laptop that the
# SaaS tenant cannot reach. In production you'd host the SPIRE OIDC
# discovery provider on a reachable HTTPS endpoint and point the
# authenticator's 'jwks-uri' at it instead - or use CyberArk's
# Secure Workload Access (SWA), which manages the JWKS endpoint for you.
#
# NOTE: SPIRE rotates its signing keys (default ~24h). If authentication
# starts failing with signature errors, re-run this script and re-set the
# public-keys variable.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

docker exec spire-server /opt/spire/bin/spire-server bundle show -format spiffe \
  | jq '{keys: [.keys[] | select(.use == "jwt-svid") | del(.use)]}' > jwks.json

jq -c '{type: "jwks", value: .}' jwks.json > public-keys.json

echo "Wrote jwks.json and public-keys.json ($(jq '.keys | length' jwks.json) signing key(s))."
