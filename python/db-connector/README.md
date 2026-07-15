# Python DB Connector

Demonstrates a service pulling **database credentials** dynamically from
Idira Secrets Manager, using API-key (`authn`) authentication via CyberArk's
official [`conjur-api`](https://pypi.org/project/conjur-api/) Python SDK -
the same SDK CyberArk documents for Secrets Manager SaaS.

- `hardcoded_app.py` - BEFORE: credentials hardcoded in source.
- `vault_app.py` - AFTER: credentials fetched at runtime via `idira_client.py`.
- `idira_client.py` - thin wrapper around `conjur_api.Client` so the call
  site (`client.get_secret(path)`) stays the same as the other samples.

Note: the SDK's `conjur_api.Client` is async by default. `idira_client.py`
passes `async_mode=False` so `get_secret()` can stay a plain synchronous
call, matching the other language samples in this repo.

Requires Python 3.10.1+ (the `conjur-api` package's minimum supported
version). If your default interpreter is older, `pip install` will pick an
older, unconstrained `conjur-api` release and then fail trying to build its
`cryptography` dependency from source. A `.python-version` file pins this
directory to 3.12.9 via [pyenv](https://github.com/pyenv/pyenv) - install it
once with `pyenv install 3.12.9` if you don't already have it.

## Setup

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Run the "before" version

```bash
python hardcoded_app.py
```

## Run the "after" version

Set the connection details for your Idira Secrets Manager instance:

```bash
export IDIRA_URL="https://mytenant.secretsmgr.cyberark.cloud/api"  # note the /api suffix
export IDIRA_ACCOUNT="conjur"
export IDIRA_LOGIN="host/data/app-db-connector"  # host/ + full path of the workload
export IDIRA_API_KEY="<api key for the above login>"

python vault_app.py
```

`vault_app.py` expects the following variables to exist in the vault
(adjust `SECRET_PATH_*` in the script if your policy uses different paths):

```
data/vault/SM-DB-SecretHub/app-db/username
data/vault/SM-DB-SecretHub/app-db/password
```
