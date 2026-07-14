#!/usr/bin/env bash
# This is "the app" for the Summon sample. Unlike the other three samples in
# this repo, this script has NO knowledge of Idira Secrets Manager at all -
# no client, no import, no REST calls. It just reads NOTIFY_API_TOKEN from
# its environment, the way countless real services already read config.
#
# That's the point: with Summon, adopting a secrets manager doesn't require
# touching app code - see hardcoded-app.sh vs vault-app.sh in this directory.
set -euo pipefail

: "${NOTIFY_API_TOKEN:?NOTIFY_API_TOKEN is not set}"

echo "Sending notification using token ${NOTIFY_API_TOKEN:0:8}..."
# curl -s -X POST -H "Authorization: Bearer ${NOTIFY_API_TOKEN}" \
#   -d '{"message":"deploy complete"}' https://notify.example.com/api/send
echo "Notification sent (simulated)."
