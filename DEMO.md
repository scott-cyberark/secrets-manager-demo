# Demo Runbook

How to execute each sample, ordered along the maturity ladder so each demo
tops the previous one. Unless flagged, setup is already done (see each
sample's README for the one-time setup it needed).

**Pre-flight (before presenting):**

- `conjur login` — the CLI session expires periodically
- `docker ps` — for the SPIFFE demo, `spire-server` and `spire-agent`
  should be up (if not: `spiffe/run-demo.sh` + `spiffe/setup-conjur.sh`)
- `aws sts get-caller-identity` — for the dynamic-secrets demo

---

## 1. The "before" pictures (hardcoded — rung 1)

No setup; the point is the credential sitting in plain source:

```bash
python3 python/db-connector/hardcoded_app.py
node nodejs/payment-api/hardcoded-app.js
bash bash/cloud-cli/hardcoded-app.sh
```

**Talking point:** open the file first and point at the credential — then
`git log` to note it lives in history forever.

## 2. Fetched at runtime (rung 2) — python, node, bash

Same pattern for all three. Each directory has a gitignored `.env` holding
its workload's identity (the *only* credential the app environment keeps):

```bash
cd python/db-connector
set -a; source .env; set +a
.venv/bin/python vault_app.py        # prints user AND password fetched live

cd ../../nodejs/payment-api
set -a; source .env; set +a
node vault-app.js

cd ../../bash/cloud-cli
set -a; source .env; set +a
./vault-app.sh
```

**Talking points:**

- Diff `hardcoded_app.py` vs `vault_app.py` — the change is tiny.
- Show the secrets in the UI under `data/demo-apps/`.
- Change a value in the UI and re-run — new value picked up, no redeploy.

## 3. Summon (rung 2, zero code changes)

⚠️ One-time install: `brew install cyberark/tools/summon cyberark/tools/summon-conjur`

```bash
cd summon/notification-service
set -a; source .env; set +a       # its .env carries the CONJUR_* vars summon reads
./hardcoded-app.sh                # BEFORE: token exported in the wrapper
./vault-app.sh                    # AFTER: summon injects it; notify.sh untouched
```

**Talking point:** `notify.sh` is byte-identical in both runs — the
retrofit story for apps you can't (or won't) modify.

## 4. GitHub Actions (rung 3 — platform identity, no stored secret)

Trigger: any push to `main`, or repo → **Actions** →
"Fetch and Display Idira Secret" → **Run workflow**.

**Talking points:**

- Repo Settings → Secrets holds only `IDIRA_URL` / `IDIRA_ACCOUNT` —
  neither is sensitive. There is no stored credential.
- GitHub's OIDC token *is* the identity; Conjur validates it via
  `authn-jwt/github`.
- This one reads the real Privilege Cloud safe
  (`data/vault/SM-AWS-SecretHub/aws-dummy-account`) via the Vault
  Synchronizer — the full PAM → Conjur → CI chain, including CPM rotation
  upstream.

## 5. SPIFFE (rung 3, on-prem flavor — secret zero eliminated)

If the SPIRE stack is already up:

```bash
cd spiffe
docker compose run --rm workload
```

If the stack was restarted, or SPIRE rotated its signing keys (~daily):

```bash
./run-demo.sh        # SPIRE up + workload registered + fresh JWKS export
./setup-conjur.sh    # re-sets public-keys etc. (idempotent; needs conjur login)
docker compose run --rm workload
```

**Talking points:**

- `cat workload/Dockerfile` — no `.env`, no key, no credential of any kind.
- The output prints the attested identity
  (`spiffe://demo.ingen.lab/report-service`) before fetching the secret.
- Show the host `data/spiffe-apps/spiffe://demo.ingen.lab/report-service`
  in the UI — the workload's SPIFFE ID *is* its identity.
- Productized version of this pattern: CyberArk Secure Workload Access (SWA).

## 6. AWS dynamic secrets (rung 4 — the closer)

```bash
cd aws-dynamic
./vault-app.sh
```

**Talking points:**

- `ASIA` key prefix = temporary STS credential (vs `AKIA` long-lived).
- The AWS-side identity is `federated-user/conjur-host-data-cloud-cli` —
  CloudTrail entries trace to the exact workload.
- Run it twice: different credentials every fetch.
- Try `aws s3 mb s3://nope` with the minted creds: denied — the inline
  policy allows `s3:ListAllMyBuckets` only.
- Wait 15 minutes: the credentials are dead. Nothing stored, nothing to
  rotate, nothing to leak.
- Show `data/dynamic/demo-s3-reader` in the UI (Resources → filter
  Secrets → Dynamic).

---

## The narrative in one line

> "First we moved secrets out of code (2–3), then we removed the bootstrap
> credential (4–5), then we stopped storing the secret at all (6)."

## Mid-demo gotchas

- `conjur login` and the MCP server's OAuth session both expire — re-login
  before presenting.
- SPIFFE auth failing with a signature error = SPIRE's ~daily signing-key
  rotation: `spiffe/scripts/export-jwks.sh` then re-run
  `spiffe/setup-conjur.sh`.
- The demo tenant's secrets and workloads are documented in each sample's
  README; the AWS issuer's IAM user is `idira-dynamic-issuer-demo` in the
  sandbox account.
