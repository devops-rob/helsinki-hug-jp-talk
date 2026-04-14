# Vault Jumppad Demo

A self-contained [Jumppad](https://jumppad.dev) environment that spins up a HashiCorp Vault server (backed by Consul) in a local container and auto-initialises it via Terraform. Built for the Helsinki HUG talk as a quick way to get a working Vault instance without manual setup.

## Requirements

1. Docker or Podman
2. [Jumppad](https://jumppad.dev/docs/install)
3. Vault CLI

## Usage

Bring up the environment:

```bash
jumppad up .
```

Jumppad will start Consul and Vault, then run the Terraform init module to unseal Vault and generate a root token.

Export the Vault CLI environment variables (`VAULT_ADDR`, `VAULT_TOKEN`):

```bash
eval $(jumppad env)
```

Check that Vault is up and unsealed:

```bash
vault status
```

To retrieve the Vault address, unseal keys, or root token at any time:

```bash
jumppad output
```

## Cleanup

Tear down the environment:

```bash
jumppad down .
```

Remove any leftover containers Jumppad created:

```bash
jumppad purge
```
