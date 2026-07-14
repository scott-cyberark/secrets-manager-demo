# Idira Secrets Manager Demo

Sample apps showing how different kinds of workloads pull secrets
**dynamically** from Idira Secrets Manager SaaS instead of hardcoding them.

Each sample ships two versions:

- `hardcoded-*` / `hardcoded_app.*` - **BEFORE**: credentials baked into source.
- `vault-*` / `vault_app.*` - **AFTER**: credentials fetched at runtime from the vault.

| Sample | Language | Secret type | Auth method | Integration style |
| --- | --- | --- | --- | --- |
| [.github/workflows/secrets.yml](.github/workflows/secrets.yml) | GitHub Actions | DB-style username/password | JWT (GitHub OIDC) via `authn-jwt` | Official CyberArk GitHub Action |
| [python/db-connector](python/db-connector) | Python | Database credentials | API key (`authn`) | Official `conjur-api` SDK |
| [nodejs/payment-api](nodejs/payment-api) | Node.js | Third-party API key | API key (`authn`) | Hand-rolled REST client (no official Node SDK exists) |
| [bash/cloud-cli](bash/cloud-cli) | Bash | Cloud provider credentials (AWS) | API key (`authn`) | Hand-rolled REST client (`curl`) |
| [summon/notification-service](summon/notification-service) | Bash (app is vault-agnostic) | Third-party API key | API key (`authn`), via `summon-conjur` | Summon process wrapper - zero app code changes |

The `python`, `nodejs`, and `bash` samples each modify the app itself to call
out to the vault (either via an SDK or its REST API), using the same
"Safe/Secret" path convention as the GitHub Actions workflow
(`data/vault/<Safe>/<secret>`). Each app's own README documents the exact
paths it expects and the environment variables it needs
(`IDIRA_URL`, `IDIRA_ACCOUNT`, `IDIRA_LOGIN`, `IDIRA_API_KEY`).

The `summon` sample is different on purpose: the app (`notify.sh`) never
references the vault at all. [Summon](https://github.com/cyberark/summon)
wraps the process and injects secrets as env vars, which is the standard
answer for languages/tools without an official SDK (like Node.js) or for
retrofitting secrets management onto an app you'd rather not touch.

## Suggested demo flow

1. Run the `hardcoded-*` version of a sample - point out the credential sitting in plain source (or, for the Summon sample, exported before the process starts).
2. Show the same secret loaded into Idira Secrets Manager.
3. Run the `vault-*` version with the sample's required env vars set - same app behavior, no embedded secret.
4. Diff `hardcoded_app.py` vs `vault_app.py` (or the `.js`/`.sh` equivalents) to show how small the change is - and for the Summon sample, show that `notify.sh` doesn't change at all.
