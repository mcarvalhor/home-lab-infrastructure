resource "docker_image" "wireguard_image" {
  name         = "linuxserver/wireguard:latest"
  keep_locally = true
}

resource "docker_volume" "vol_wireguard_data" {
  name = "wireguard_data"
}

resource "docker_container" "wireguard" {
  name    = "wireguard"
  image   = docker_image.wireguard_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 51820
    external = 51820
    protocol = "udp"
  }
  env = [
    "ALLOWEDIPS=0.0.0.0/0",
    "DEBIAN_FRONTEND=noninteractive",
    "HOME=/root",
    "INTERNAL_SUBNET=10.2.0.1",
    "LANG=en_US.UTF-8",
    "LANGUAGE=en_US.UTF-8",
    "LOG_CONFS=false",
    "LSIO_FIRST_PARTY=true",
    "PEERDNS=auto",
    "PEERS=mcarvalhor,or01",
    "PGID=1000",
    "PS1=$(whoami)@$(hostname):$(pwd)\\$",
    "PUID=1000",
    "S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0",
    "S6_STAGE2_HOOK=/docker-mods",
    "S6_VERBOSITY=1",
    "SERVERPORT=51820",
    "SERVERURL=vpn.cluster.mcarvalhor.com",
    "TERM=xterm",
    "TZ=America/Sao_Paulo",
    "VIRTUAL_ENV=/lsiopy",
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
