#!/usr/bin/env bash
# Configures the authn-jwt/spire authenticator in Idira Secrets Manager.
# Prerequisites: 'conjur login' completed, and run-demo.sh already run
# (it generates public-keys.json from the live SPIRE server).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

[ -f public-keys.json ] || { echo "public-keys.json missing - run ./run-demo.sh first"; exit 1; }

echo "==> Loading authenticator policy (conjur/authn-jwt/spire)..."
conjur policy load -b conjur/authn-jwt -f policy/authn-jwt-spire.yml

echo "==> Setting authenticator variables..."
conjur variable set -i conjur/authn-jwt/spire/public-keys -v "$(cat public-keys.json)"
conjur variable set -i conjur/authn-jwt/spire/token-app-property -v "sub"
conjur variable set -i conjur/authn-jwt/spire/identity-path -v "data/spiffe-apps"
conjur variable set -i conjur/authn-jwt/spire/issuer -v "https://spire.demo.ingen.lab"
conjur variable set -i conjur/authn-jwt/spire/audience -v "conjur"

echo "==> Creating the SPIFFE workload identity (data/spiffe-apps)..."
conjur policy load -b data -f policy/spiffe-apps.yml

echo "==> Granting the workloads group access to the authenticator..."
conjur policy load -b conjur/authn-jwt/spire -f policy/grant-authn-access.yml

echo "==> Granting read on the demo secret..."
conjur policy load -b data/demo-apps -f policy/secret-access.yml

echo "==> Enabling the authenticator..."
conjur authenticator enable --id authn-jwt/spire

echo
echo "Done. Run the workload with:  docker compose run --rm workload"
