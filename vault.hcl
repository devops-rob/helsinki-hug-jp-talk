resource "container" "vault" {
  depends_on = ["resource.container.consul"]

  network {
    id      = resource.network.local.meta.id
    aliases = ["vault_ip_address"]
  }

  image {
    name = "hashicorp/vault:1.21"
  }

  command = [
    "server",
    "-config=/files/vault.hcl"
  ]

  capabilities {
    add = ["IPC_LOCK"]
  }



  environment = {
    VAULT_ADDR = "http://localhost:8200"
  }


  port {
    local  = 8200
    remote = 8200
    host   = 8200
  }

  volume {
    source      = "./config/vault"
    destination = "/files"
  }

  volume {
    source      = "${data("temp")}"
    destination = "/vault/data"
  }

}

resource "terraform" "init" {
  source            = "./terraform/vault-init"
  working_directory = "/"
  version           = "1.14.8"

  network {
    id = resource.network.local.meta.id
  }

  variables = {
    vault_addr = "http://${resource.container.vault.container_name}:8200"
  }
}

output "unseal_keys" {
  value = resource.terraform.init.output.vault_init_unseal_keys
}

output "VAULT_ADDR" {
  value = "http://${resource.container.vault.container_name}:8200"
}

output "VAULT_ROOT_TOKEN" {
  value = resource.terraform.init.output.vault_init_root_token
}
