# 1. jp_network_resource https://jumppad.dev/docs/resources/network
resource "network" "local" {
    subnet = "10.10.0.0/16"
}
