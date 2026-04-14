# 3. jp_vault_resource https://jumppad.dev/docs/resources/container/container
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

    health_check {
      timeout = "30s"
      http {
        address = "http://localhost:8200/v1/sys/health?sealedcode=200&uninitcode=200"
        success_codes = [200]
      }
    }

}

# 4. jp_vault_init https://jumppad.dev/docs/resources/terraform
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

  depends_on = ["resource.container.vault"]
  
}

# 5. jp_terraform_template_resource https://jumppad.dev/docs/resources/template
resource "template" "terraform_oidc" {
  source      = file("./terraform/vault-oidc/main.tpl")
  destination = "./terraform/vault-oidc/main.tf"

  variables = {
    vault_addr  = resource.container.vault.container_name
    vault_token = resource.terraform.init.output.vault_init_root_token
    nomad_addr  = resource.nomad_cluster.dev.server_container_name
  }
}

#6. jp_vault_configuration https://jumppad.dev/docs/resources/terraform
resource "terraform" "vault_configure" {

  depends_on = ["resource.template.terraform_oidc"]

  source            = "./terraform/vault-oidc"
  version           = "1.14.8"
  working_directory = "/"


  network {
    id = resource.network.local.meta.id
  }
}

# 7 jp_output_unseal_keys https://jumppad.dev/docs/resources/internal/output
output "unseal_keys" {
  value = resource.terraform.init.output.vault_init_unseal_keys
}

# 8. jp_output_vault_addr https://jumppad.dev/docs/resources/internal/output
output "VAULT_ADDR" {
  value = "http://${resource.container.vault.container_name}:8200"
}

# 9. jp_output_vault_root_token https://jumppad.dev/docs/resources/internal/output
output "VAULT_ROOT_TOKEN" {
  value = resource.terraform.init.output.vault_init_root_token
}
