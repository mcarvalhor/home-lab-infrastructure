resource "docker_image" "wireguard_image" {
  name          = "ghcr.io/wg-easy/wg-easy:edge"
  keep_locally  = false
  pull_triggers = [local.last_deployment.wireguard]
}

resource "docker_volume" "vol_wireguard_data" {
  name = "wireguard_data"
}

resource "docker_container" "wireguard" {
  name         = "wireguard"
  image        = docker_image.wireguard_image.image_id
  restart      = "unless-stopped"
  network_mode = "host"
  capabilities {
    add = ["CAP_NET_ADMIN", "CAP_SYS_MODULE"]
  }
  env = [
    "WG_ALLOWED_IPS=0.0.0.0/0, ::/0",
    "WG_HOST=vpn.mcarvalhor.com",
    "WG_PORT=${local.ports.wireguard_vpn}",
    "WG_MTU=null",
    "WG_PERSISTENT_KEEPALIVE=0",
    "WG_DEFAULT_ADDRESS=10.2.0.1",
    "WG_DEFAULT_DNS=1.1.1.1, 1.0.0.1",
    "PORT=${local.ports.wireguard_web}",
    "HOST=0.0.0.0",
    "INSECURE=true",
  ]
  volumes {
    volume_name    = docker_volume.vol_wireguard_data.name
    container_path = "/etc/wireguard"
  }
  volumes {
    host_path      = "/lib/modules"
    container_path = "/lib/modules"
    read_only      = true
  }
}
