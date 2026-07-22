resource "docker_image" "wireguard_image" {
  name          = "linuxserver/wireguard:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.wireguard]
}

resource "docker_volume" "vol_wireguard_data" {
  name = "wireguard_data"
}

resource "docker_container" "wireguard" {
  name    = "wireguard"
  image   = docker_image.wireguard_image.image_id
  restart = "unless-stopped"
  network_mode = "host"
  capabilities {
    add = ["CAP_NET_ADMIN", "CAP_SYS_MODULE"]
  }
  env = [
    "ALLOWEDIPS=0.0.0.0/0,::/0",
    "INTERNAL_SUBNET=10.2.0.1,fd8c:1111:2222::/64",
    "PEERDNS=1.1.1.1,1.0.0.1,2606:4700:4700::1111,2606:4700:4700::1001",
    "PEERS=c01,mcarvalhor",
    "SERVERPORT=${local.ports.wireguard_vpn}",
    "SERVERURL=vpn.cluster.mcarvalhor.com",
    "TZ=America/Sao_Paulo",
  ]
  volumes {
    volume_name    = docker_volume.vol_wireguard_data.name
    container_path = "/config"
  }
  volumes {
    host_path      = "/lib/modules"
    container_path = "/lib/modules"
    read_only      = true
  }
}
