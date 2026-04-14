resource "container" "vault" {
    depends_on = ["resource.container.consul"]

    network {
        id         = resource.network.local.meta.id
        aliases    = ["vault_ip_address"]
    }

    image {
        name     = "hashicorp/vault:1.21"
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

resource "terraform" "init" {
  source            = "./terraform/vault-init"
  working_directory = "/"
  version           = "1.14.8"

  network {
    id = resource.network.local.meta.id
  }

  depends_on = ["resource.container.vault"]
  
}

resource "template" "terraform_oidc" {
  source      = file("./terraform/vault-oidc/main.tpl")
  destination = "./terraform/vault-oidc/main.tf"

  variables = {
    vault_addr  = resource.container.vault.container_name
    vault_token = resource.terraform.init.output.vault_init_root_token
    nomad_addr  = resource.nomad_cluster.dev.server_container_name
  }
}

resource "terraform" "vault_configure" {

  depends_on = ["resource.template.terraform_oidc"]

  source            = "./terraform/vault-oidc"
  version           = "1.14.8"
  working_directory = "/"


  network {
    id = resource.network.local.meta.id
  }
}


output "unseal_keys" {
  value = resource.terraform.init.output.keys
}

output "root_token" {
  value = resource.terraform.init.output.root_token
}
