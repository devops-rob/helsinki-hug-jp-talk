job "web" {
  datacenters = ["dc1"]

  group "web" {
    network {
      mode = "bridge"

      port "http" {
        to = 5678
      }
    }

    service {
      name = "web"
      port = "http"

      check {
        name     = "web alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "web" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo"
        args  = [
          "-listen=:5678",
          "-text=hello from nomad"
        ]

        ports = ["http"]
      }
    }
  }
}