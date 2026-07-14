#!/usr/bin/env bash
# BEFORE: token hardcoded / exported manually before running the app.
set -euo pipefail

export NOTIFY_API_TOKEN="tok_live_abcdefghijklmnop" # <-- hardcoded, bad

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/notify.sh"
