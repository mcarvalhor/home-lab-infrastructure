resource "docker_image" "wireguard_client_image" {
  name          = "linuxserver/wireguard:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.wireguard]
}

resource "docker_volume" "vol_wireguard_client_data" {
  name = "wireguard_data"
}

resource "docker_container" "wireguard_client" {
  name         = "wireguard-client"
  image        = docker_image.wireguard_image.image_id
  restart      = "unless-stopped"
  network_mode = "host"
  capabilities {
    add = ["CAP_NET_ADMIN", "CAP_SYS_MODULE"]
  }
  volumes {
    host_path      = abspath("${path.root}/configs/wireguard-client.conf")
    container_path = "/config/wg0.conf"
    read_only      = true
  }
  volumes {
    host_path      = "/lib/modules"
    container_path = "/lib/modules"
    read_only      = true
  }
}
