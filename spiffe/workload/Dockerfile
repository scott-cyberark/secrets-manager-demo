# Demo workload image: a plain alpine container with the spire-agent CLI
# (used only as a Workload API client) and curl/jq for talking to
# Idira Secrets Manager. Note what is NOT here: no API key, no .env,
# no baked-in credentials of any kind.
FROM ghcr.io/spiffe/spire-agent:1.10.0 AS spire

FROM alpine:3.20
RUN apk add --no-cache bash curl jq
COPY --from=spire /opt/spire/bin/spire-agent /usr/local/bin/spire-agent
COPY vault-app.sh /usr/local/bin/vault-app.sh
RUN chmod +x /usr/local/bin/vault-app.sh

# UID 1001 is this workload's attested identity selector (unix:uid:1001)
USER 1001
ENTRYPOINT ["/usr/local/bin/vault-app.sh"]
