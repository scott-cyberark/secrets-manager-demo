# AWS Dynamic Secrets

Demonstrates **dynamic secrets**: instead of storing an AWS credential in
the vault (static) or rotating one there (CPM-managed), Idira Secrets
Manager **mints fresh STS credentials on every fetch**, scoped by an
inline policy and dead within 15 minutes. There is nothing long-lived to
steal, leak, or rotate.

Compare with [bash/cloud-cli](../bash/cloud-cli), which fetches *static*
AWS keys - same workload identity, very different secret lifecycle:

| | Static secret | Dynamic secret |
| --- | --- | --- |
| What's stored | The actual AWS key | Nothing (an issuer mints on demand) |
| Lifetime | Until rotated | TTL (15 min here), then self-destructs |
| Scope | Whatever the key can do | Narrowed per-secret by inline policy |
| Rotation | CPM / manual | Not needed - every fetch is new |

## How it works

1. A Secrets Manager **issuer** (`aws-demo-issuer`) holds the access key of
   a minimal IAM user (`idira-dynamic-issuer-demo`) whose only powers are
   `sts:GetFederationToken` and `s3:ListAllMyBuckets`.
2. A **dynamic secret resource** (`data/dynamic/demo-s3-reader`) references
   the issuer, sets a 900s TTL, and attaches an inline policy allowing only
   `s3:ListAllMyBuckets`.
3. When the workload fetches the secret, AWS returns federation-token
   credentials valid for 15 minutes whose permissions are the
   *intersection* of the IAM user's policy and the inline policy.

## Setup (one time)

```bash
# Prereqs: 'aws configure' (sandbox admin) + 'conjur login'
./setup-aws.sh      # IAM user + access key, piped straight into the issuer
./setup-conjur.sh   # dynamic secret resource + workload grant
```

## Run

```bash
./vault-app.sh      # authenticates as the cloud-cli workload
```

Expected output: a `GetFederationToken` caller identity
(`arn:aws:sts::<account>:federated-user/conjur,demo-s3-reader,...`), an S3
bucket listing, and credentials that expire ~15 minutes later.
