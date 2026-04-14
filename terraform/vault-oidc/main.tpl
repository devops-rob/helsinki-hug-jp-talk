terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.3.0"
    }
  }
}


provider "vault" {
  address = "http://{{vault_addr}}:8200"
  token   = "{{vault_token}}"
}

resource "vault_mount" "transit" {
  path = "transit"
  type = "transit"
}

resource "vault_transit_secret_backend_key" "demo" {
  backend               = vault_mount.transit.path
  name                  = "demo-key"
  convergent_encryption = true
  derived               = true
}

resource "vault_policy" "demo" {
  name   = "demo"
  policy = <<EOF
path "transit/demo-key/*" {
  capabilities = [
    "create",
    "read",
    "update",
    "list"
  ]
}
EOF
}

resource "vault_jwt_auth_backend" "jwt_dev" {
  path         = "jwt"
  type         = "jwt"
  jwks_url     = "http://{{nomad_addr}}:4646/.well-known/jwks.json"
  bound_issuer = "http://{{nomad_addr}}:4646"
  tune {
    listing_visibility = "unauth"
  }
}

resource "vault_jwt_auth_backend_role" "example" {
  backend        = vault_jwt_auth_backend.jwt_dev.path
  role_name      = "test-role"
  token_policies = ["default", "demo"]

  bound_claims = {
    nomad_namespace = "default"
    nomad_task      = "demo"
    nomad_job_id    = "demo"
  }

  bound_audiences = [
    "nomadproject.io"
  ]
  user_claim = "sub"
  role_type  = "jwt"
}