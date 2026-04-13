bind_addr = "0.0.0.0"

advertise {
  http = "server.dev.nomad-cluster.local.jmpd.in:4646"
  rpc  = "server.dev.nomad-cluster.local.jmpd.in:4647"
  serf = "server.dev.nomad-cluster.local.jmpd.in:4648"
}

vault {
  enabled = true

  default_identity {
    aud = ["vault.io"]
    ttl = "1h"
  }
}

consul {
  address = "consul.container.local.jmpd.in:8500"
}