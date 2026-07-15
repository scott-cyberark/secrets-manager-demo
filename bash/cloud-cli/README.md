# Bash Cloud CLI

Demonstrates a script pulling **cloud provider credentials** (AWS
access key/secret) dynamically from Idira Secrets Manager, using API-key
(`authn`) authentication and plain `curl`.

- `hardcoded-app.sh` - BEFORE: credentials hardcoded in the script.
- `vault-app.sh` - AFTER: credentials fetched at runtime via `idira-client.sh`.
- `idira-client.sh` - shared curl-based helper functions (authenticate + fetch secret).

Requires: `bash`, `curl`, `base64` (all standard on macOS/Linux).

## Run the "before" version

```bash
./hardcoded-app.sh
```

## Run the "after" version

Set the connection details for your Idira Secrets Manager instance:

```bash
export IDIRA_URL="https://idira.example.com"
export IDIRA_ACCOUNT="myorg"
export IDIRA_LOGIN="host/cloud-cli-client"
export IDIRA_API_KEY="<api key for the above login>"

./vault-app.sh
```

`vault-app.sh` expects the following variables to exist in the vault (adjust
`SECRET_PATH_*` in the script if your policy uses different paths):

```
data/demo-apps/cloud-app/aws_access_key_id
data/demo-apps/cloud-app/aws_secret_access_key
```
