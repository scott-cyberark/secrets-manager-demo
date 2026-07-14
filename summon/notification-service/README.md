# Summon Notification Service

Demonstrates the **zero-app-code-change** integration pattern: instead of an
app calling out to the vault, [Summon](https://github.com/cyberark/summon)
(CyberArk's env-injection CLI) wraps the process, fetches secrets from Idira
Secrets Manager, and injects them as environment variables for that process
only. This is a different integration style from the other three samples in
this repo, which each modify app code to talk to the vault directly.

- `notify.sh` - the app. It only reads `NOTIFY_API_TOKEN` from its
  environment and has no idea Idira Secrets Manager exists.
- `hardcoded-app.sh` - BEFORE: exports a hardcoded token, then runs `notify.sh`.
- `vault-app.sh` - AFTER: runs the *exact same* `notify.sh` under `summon`.
- `secrets.yml` - maps the `NOTIFY_API_TOKEN` env var to a vault variable ID.

## Prerequisites

Install Summon and the `summon-conjur` provider (which Idira Secrets Manager
SaaS is built on):

```bash
brew tap cyberark/tools
brew install summon
brew install summon-conjur
```

(Linux/Windows installers: see
[cyberark/summon](https://github.com/cyberark/summon#installation) and
[cyberark/summon-conjur](https://github.com/cyberark/summon-conjur).)

## Run the "before" version

```bash
./hardcoded-app.sh
```

## Run the "after" version

`summon-conjur` reads its connection/auth config from Conjur's native env
var names (not this repo's `IDIRA_*` convention, since it's a third-party
provider binary):

```bash
export CONJUR_APPLIANCE_URL="https://idira.example.com"
export CONJUR_ACCOUNT="myorg"
export CONJUR_AUTHN_LOGIN="host/notification-service"
export CONJUR_AUTHN_API_KEY="<api key for the above login>"

./vault-app.sh
```

`vault-app.sh` expects the following variable to exist in the vault (adjust
`secrets.yml` if your policy uses a different path):

```
data/vault/SM-API-SecretHub/notification-service/api_token
```

Compare `hardcoded-app.sh` and `vault-app.sh` side by side: the *app itself*
(`notify.sh`) doesn't change at all between the before and after states.
