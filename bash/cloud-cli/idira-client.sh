#!/usr/bin/env bash
# Shared helper functions for authenticating to Idira Secrets Manager and
# fetching secrets over its REST API using curl.
#
# Auth flow:
#   1. POST the API key to /authn/{account}/{login}/authenticate -> raw signed token
#   2. Base64-encode that token and send it as `Authorization: Token token="..."`
#      on subsequent requests.
#   3. GET /secrets/{account}/variable/{path} to read a secret value.
#
# Requires: IDIRA_URL, IDIRA_ACCOUNT, IDIRA_LOGIN, IDIRA_API_KEY environment
# variables to be set by the caller.

idira_urlencode() {
  local string="$1"
  local length="${#string}"
  local i c
  for (( i = 0; i < length; i++ )); do
    c="${string:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
      *) printf '%%%02X' "'$c" ;;
    esac
  done
}

idira_authenticate() {
  local login_encoded
  login_encoded=$(idira_urlencode "$IDIRA_LOGIN")

  curl --silent --show-error --fail \
    --request POST \
    --data "$IDIRA_API_KEY" \
    --header "Content-Type: text/plain" \
    "${IDIRA_URL%/}/authn/${IDIRA_ACCOUNT}/${login_encoded}/authenticate" \
    | base64 | tr -d '\n'
}

idira_get_secret() {
  local secret_path="$1"
  local token="$2"
  local path_encoded
  path_encoded=$(idira_urlencode "$secret_path")

  curl --silent --show-error --fail \
    --header "Authorization: Token token=\"${token}\"" \
    "${IDIRA_URL%/}/secrets/${IDIRA_ACCOUNT}/variable/${path_encoded}"
}
