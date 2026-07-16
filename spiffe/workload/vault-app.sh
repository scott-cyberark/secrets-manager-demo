#!/usr/bin/env bash
# SPIFFE-attested workload - the "no secret zero" version.
#
# This app authenticates to Idira Secrets Manager WITHOUT any stored
# credential. Its identity is attested at runtime by the SPIRE agent
# (via the Unix workload attestor - this process's UID), which issues a
# short-lived JWT-SVID. Secrets Manager's JWT authenticator validates the
# SVID and maps its 'sub' claim to a workload identity.
set -euo pipefail

: "${IDIRA_URL:?}" "${IDIRA_ACCOUNT:?}" "${AUTHN_ID:?}" "${SPIFFE_AUD:?}" "${SECRET_ID:?}"
SOCKET="/tmp/spire-agent/public/api.sock"

echo "[1/3] Requesting JWT-SVID from the SPIRE Workload API (no credentials presented)..."
SVID=$(spire-agent api fetch jwt -audience "$SPIFFE_AUD" -socketPath "$SOCKET" \
  | sed -n '2p' | tr -d '[:space:]')
SUB=$(echo "$SVID" | cut -d. -f2 | tr '_-' '/+' | { read -r p; pad=$(( (4 - ${#p} % 4) % 4 )); printf '%s' "$p"; printf '=%.0s' $(seq 1 $pad) 2>/dev/null; } | base64 -d 2>/dev/null | jq -r .sub)
echo "      Attested identity: ${SUB}"

echo "[2/3] Exchanging the JWT-SVID for a Secrets Manager access token..."
CONJUR_TOKEN=$(curl -sf -X POST \
  "${IDIRA_URL}/authn-jwt/${AUTHN_ID}/${IDIRA_ACCOUNT}/authenticate" \
  -H 'Accept-Encoding: base64' \
  --data-urlencode "jwt=${SVID}")

echo "[3/3] Fetching secret '${SECRET_ID}'..."
ENCODED_ID=$(jq -rn --arg s "$SECRET_ID" '$s|@uri')
SECRET=$(curl -sf \
  -H "Authorization: Token token=\"${CONJUR_TOKEN}\"" \
  "${IDIRA_URL}/secrets/${IDIRA_ACCOUNT}/variable/${ENCODED_ID}")

echo
echo "Success! Retrieved secret value: ${SECRET}"
echo "Zero stored credentials were used - identity was attested by SPIFFE."
