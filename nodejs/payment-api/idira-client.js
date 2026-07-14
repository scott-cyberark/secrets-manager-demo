"use strict";

/**
 * Minimal REST client for Idira Secrets Manager (Conjur-compatible API).
 *
 * Auth flow:
 *   1. POST the API key to /authn/{account}/{login}/authenticate -> raw signed token
 *   2. Base64-encode that token and send it as `Authorization: Token token="..."`
 *      on subsequent requests.
 *   3. GET /secrets/{account}/variable/{path} to read a secret value.
 *
 * Configure via environment variables (or pass explicitly to the constructor):
 *   IDIRA_URL, IDIRA_ACCOUNT, IDIRA_LOGIN, IDIRA_API_KEY
 *
 * Requires Node.js 18+ (global fetch).
 */
class IdiraClient {
  constructor({ url, account, login, apiKey } = {}) {
    this.url = (url || process.env.IDIRA_URL || "").replace(/\/$/, "");
    this.account = account || process.env.IDIRA_ACCOUNT;
    this.login = login || process.env.IDIRA_LOGIN;
    this.apiKey = apiKey || process.env.IDIRA_API_KEY;
    this.token = null;
  }

  async _authenticate() {
    const loginEncoded = encodeURIComponent(this.login);
    const res = await fetch(
      `${this.url}/authn/${this.account}/${loginEncoded}/authenticate`,
      {
        method: "POST",
        headers: { "Content-Type": "text/plain" },
        body: this.apiKey,
      }
    );
    if (!res.ok) {
      throw new Error(
        `Idira authentication failed: ${res.status} ${res.statusText}`
      );
    }
    const rawToken = await res.text();
    this.token = Buffer.from(rawToken).toString("base64");
    return this.token;
  }

  _fetchSecret(pathEncoded) {
    return fetch(
      `${this.url}/secrets/${this.account}/variable/${pathEncoded}`,
      { headers: { Authorization: `Token token="${this.token}"` } }
    );
  }

  async getSecret(secretPath) {
    if (!this.token) {
      await this._authenticate();
    }
    const pathEncoded = encodeURIComponent(secretPath);
    let res = await this._fetchSecret(pathEncoded);

    if (res.status === 401) {
      // Token expired (Conjur tokens are short-lived) - re-authenticate once.
      await this._authenticate();
      res = await this._fetchSecret(pathEncoded);
    }

    if (!res.ok) {
      throw new Error(
        `Failed to fetch secret ${secretPath}: ${res.status} ${res.statusText}`
      );
    }
    return res.text();
  }
}

module.exports = { IdiraClient };
