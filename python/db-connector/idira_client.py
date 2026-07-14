"""Thin wrapper around CyberArk's official `conjur-api` SDK
(https://pypi.org/project/conjur-api/), which is what Idira Secrets Manager
SaaS is built on. Keeping this wrapper means vault_app.py's call site
(`client.get_secret(path)`) doesn't need to change even though the
transport underneath is now the vendor SDK instead of hand-rolled REST
calls.

Configure via environment variables (or pass explicitly):
  IDIRA_URL, IDIRA_ACCOUNT, IDIRA_LOGIN, IDIRA_API_KEY
"""
import os

from conjur_api import Client
from conjur_api.models import ConjurConnectionInfo, CredentialsData, SslVerificationMode
from conjur_api.providers import AuthnAuthenticationStrategy, SimpleCredentialsProvider


class IdiraClient:
    def __init__(self, url=None, account=None, login=None, api_key=None):
        self.url = url or os.environ["IDIRA_URL"]
        self.account = account or os.environ["IDIRA_ACCOUNT"]
        self.login = login or os.environ["IDIRA_LOGIN"]
        self.api_key = api_key or os.environ["IDIRA_API_KEY"]
        self._client = self._build_client()

    def _build_client(self):
        connection_info = ConjurConnectionInfo(
            conjur_url=self.url,
            account=self.account,
            cert_file=None,
            service_id=None,
            proxy_params=None,
        )

        # SimpleCredentialsProvider is an in-memory-only credential store
        # (just a dict keyed by URL) - nothing is written to disk here.
        credentials_provider = SimpleCredentialsProvider()
        credentials_provider.save(
            CredentialsData(username=self.login, api_key=self.api_key, machine=self.url)
        )

        authn_strategy = AuthnAuthenticationStrategy(credentials_provider)
        # async_mode=False makes Client's methods plain synchronous calls
        # (internally wrapped in asyncio.run) instead of coroutines that
        # need to be awaited - the SDK defaults to async_mode=True.
        return Client(
            connection_info,
            authn_strategy=authn_strategy,
            ssl_verification_mode=SslVerificationMode.TRUST_STORE,
            async_mode=False,
        )

    def get_secret(self, secret_path):
        return self._client.get(secret_path).decode("utf-8")