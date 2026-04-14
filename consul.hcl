# 2. jp_consul_resource https://jumppad.dev/docs/resources/container/container
resource "container" "consul" {
    network {
        id         = resource.network.local.meta.id
        aliases    = ["consul_ip_address"]
    }

    image {
        name     = "hashicorp/consul:1.22"
    }

    command = [
        "agent",
        "-dev",
        "-client=0.0.0.0"
    ]

    environment = {
        CONSUL_HTTP_ADDR = "http://localhost:8500"
    }

    port {
        local  = 8500
        remote = 8500
        host   = 8500
    }

}
