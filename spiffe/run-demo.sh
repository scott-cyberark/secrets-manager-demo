#!/usr/bin/env bash
# Brings up the local SPIRE stack (server + agent) and registers the demo
# workload. Safe to re-run; it tears down any previous stack first.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

TRUST_DOMAIN="demo.ingen.lab"
AGENT_ID="spiffe://${TRUST_DOMAIN}/demo-agent"
WORKLOAD_ID="spiffe://${TRUST_DOMAIN}/report-service"

echo "==> Starting SPIRE server..."
docker compose down -v --remove-orphans >/dev/null 2>&1 || true
JOIN_TOKEN=unset docker compose up -d spire-server

echo "==> Waiting for the server to become healthy..."
for i in $(seq 1 30); do
  if docker exec spire-server /opt/spire/bin/spire-server healthcheck >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
docker exec spire-server /opt/spire/bin/spire-server healthcheck

echo "==> Generating a one-time join token for the agent..."
JOIN_TOKEN=$(docker exec spire-server /opt/spire/bin/spire-server token generate \
  -spiffeID "$AGENT_ID" | awk '{print $2}')

echo "==> Starting SPIRE agent..."
JOIN_TOKEN="$JOIN_TOKEN" docker compose up -d spire-agent

echo "==> Registering the demo workload (${WORKLOAD_ID}, selector unix:uid:1001)..."
docker exec spire-server /opt/spire/bin/spire-server entry create \
  -parentID "$AGENT_ID" \
  -spiffeID "$WORKLOAD_ID" \
  -selector unix:uid:1001 \
  -jwtSVIDTTL 300

echo "==> Exporting the trust domain's JWT-SVID signing keys as JWKS..."
./scripts/export-jwks.sh

echo
echo "SPIRE stack is up. Next steps:"
echo "  1. Configure the authenticator in Secrets Manager (see setup-conjur.sh)"
echo "  2. Run the workload:  docker compose run --rm workload"
