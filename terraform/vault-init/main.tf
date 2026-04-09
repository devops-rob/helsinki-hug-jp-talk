terraform {
  required_providers {
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "2.2.0"
    }
  }
}

provider "terracurl" {
  
}

resource "terracurl_request" "vault_init" {
    name = "vault_init"
    url = "http://vault.container.local.jmpd.in:8200/v1/sys/init"

    method = "POST"

    request_body = jsonencode({
        secret_shares    = 1,
        secret_threshold = 1
    })

    response_codes = ["200"]
}

resource "terracurl_request" "vault_unseal" {
    depends_on = [terracurl_request.vault_init]

    name = "vault_unseal"
    url  = "http://vault.container.local.jmpd.in:8200/v1/sys/unseal"

    method = "POST"

    request_body = jsonencode({
        key = element(jsondecode(terracurl_request.vault_init.response).keys, 0)
    })

    response_codes = ["200"]
}

output "vault_init_unseal_keys" {
    value = jsondecode(terracurl_request.vault_init.response).keys
}

output "vault_init_root_token" {
    value = jsondecode(terracurl_request.vault_init.response).root_token
}
