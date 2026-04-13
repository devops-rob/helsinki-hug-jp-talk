bind_addr = "0.0.0.0"

advertise {
  http = "client.dev.nomad-cluster.local.jmpd.in:4646"
  rpc  = "client.dev.nomad-cluster.local.jmpd.in:4647"
  serf = "client.dev.nomad-cluster.local.jmpd.in:4648"
}

vault {
  enabled = true
  address = "http://vault.container.local.jmpd.in:8200"
}

consul {
  address = "consul.container.local.jmpd.in:8500"
}