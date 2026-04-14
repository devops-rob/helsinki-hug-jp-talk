# 10 jp_nomad_cluster_resource https://jumppad.dev/docs/resources/nomad/nomad_cluster
resource "nomad_cluster" "dev" {
  depends_on = [
    "resource.container.vault",
    "resource.container.consul"
  ]

  client_nodes=0

  network {
    id = resource.network.local.meta.id
  }

  server_config = "./config/nomad/server.hcl"
  client_config = "./config/nomad/client.hcl"
}
