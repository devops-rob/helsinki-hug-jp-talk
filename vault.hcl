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

}

# resource "terraform" "init" {
#   source = "./terraform/vault-init"
#   working_directory = "/"
#   version = "1.14.8"

#   network {
#     id = resource.network.local.meta.id
#   }

#   depends_on = ["resource.container.vault"]
  
# }

# output "unseal_keys" {
#   value = resource.terraform.init.output.keys
# }

# output "root_token" {
#   value = resource.terraform.init.output.root_token
# }
