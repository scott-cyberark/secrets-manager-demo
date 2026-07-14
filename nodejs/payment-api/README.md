# Node.js Payment API Client

Demonstrates a service pulling a **third-party API key** dynamically from
Idira Secrets Manager, using API-key (`authn`) authentication.

- `hardcoded-app.js` - BEFORE: API key hardcoded in source.
- `vault-app.js` - AFTER: API key fetched at runtime via `idira-client.js`.
- `idira-client.js` - minimal REST client (authenticate + fetch secret).

Requires Node.js 18+ (uses the global `fetch`); no external dependencies.

## Run the "before" version

```bash
npm run start:hardcoded
```

## Run the "after" version

Set the connection details for your Idira Secrets Manager instance:

```bash
export IDIRA_URL="https://idira.example.com"
export IDIRA_ACCOUNT="myorg"
export IDIRA_LOGIN="host/payment-api-client"
export IDIRA_API_KEY="<api key for the above login>"

npm run start:vault
```

`vault-app.js` expects the following variable to exist in the vault (adjust
`SECRET_PATH_API_KEY` in the script if your policy uses a different path):

```
data/vault/SM-API-SecretHub/payment-api/api_key
```
