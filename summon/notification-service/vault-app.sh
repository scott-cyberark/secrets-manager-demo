#!/usr/bin/env bash
# AFTER: notify.sh is completely unchanged. Summon fetches the secret listed
# in secrets.yml from Idira Secrets Manager and injects it as an environment
# variable for this one child process only - notify.sh never finds out.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec summon --provider summon-conjur -f "${SCRIPT_DIR}/secrets.yml" "${SCRIPT_DIR}/notify.sh"
