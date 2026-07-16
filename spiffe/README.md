# SPIFFE / SPIRE: Zero-Secret Authentication

Every other sample in this repo still holds one bootstrap credential (the
workload's API key in a `.env` file) - the classic **secret zero** problem.
This sample eliminates it: the workload holds **no credentials at all**.
Its identity is *attested* at runtime by [SPIRE](https://spiffe.io) (the
reference SPIFFE implementation), which issues a short-lived JWT-SVID that
Idira Secrets Manager's JWT authenticator validates directly.

```
     attest (unix:uid:1001)      JWT-SVID (RS256, 5 min TTL)
workload ──────► SPIRE agent ──────► workload ──────► Idira authn-jwt/spire
                     │                                     │  validates sig
                     ▼                                     │  + iss + aud,
              SPIRE server                                 │  maps sub ──► host
        (trust domain demo.ingen.lab)                      ▼
                                                   secret returned
```

No `.env`, no API key, nothing to rotate, nothing to leak. Identity comes
from *what the workload is* (a process with UID 1001 on an attested node),
not *what it holds*.

## Components

- [docker-compose.yml](docker-compose.yml) - SPIRE server + agent + the demo
  workload container (which shares the agent's PID namespace so the Unix
  workload attestor can verify it).
- [policy/](policy) - the Secrets Manager side: an `authn-jwt/spire`
  authenticator validating against SPIRE's signing keys, and a workload
  identity whose host ID *is* its SPIFFE ID
  (`spiffe://demo.ingen.lab/report-service`).
- [workload/vault-app.sh](workload/vault-app.sh) - the three-step flow:
  fetch JWT-SVID from the Workload API socket → exchange it for a Secrets
  Manager token → fetch the secret.

## Setup

```bash
./run-demo.sh       # SPIRE server + agent up, workload registered, JWKS exported
./setup-conjur.sh   # authenticator + workload identity in Secrets Manager
                    # (requires 'conjur login')
```

## Run

```bash
docker compose run --rm workload
```

## Notes for production

- This demo uses a **static JWKS** (`public-keys` variable) because the
  SaaS tenant can't reach a laptop. SPIRE rotates its signing keys
  (~daily), so a long-lived setup would host SPIRE's OIDC discovery
  provider on a reachable HTTPS endpoint and use `jwks-uri` instead.
- The productized version of this pattern is CyberArk **Secure Workload
  Access (SWA)**: managed trust domains, node/workload attestation policy,
  workload inventory under `data/swa/...`, and tenant-hosted JWKS
  endpoints - same SPIFFE standard, minus the DIY plumbing.
- Real deployments attest by stronger selectors than a UID: Kubernetes
  service accounts, binary SHA-256, cloud instance identity, or X.509 PoP.
