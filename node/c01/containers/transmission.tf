resource "docker_image" "transmission_image" {
  name         = "linuxserver/transmission:latest"
  keep_locally = true
  pull_triggers = [ local.last_deployment.transmission ]
}

resource "docker_volume" "vol_transmission_ro_data" {
  name = "transmission_ro_data"
}

resource "docker_volume" "vol_transmission_rw_data" {
  name = "transmission_rw_data"
}

resource "docker_container" "transmission" {
  name    = "transmission"
  image   = docker_image.transmission_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 51413
    external = local.ports.transmission_peer
  }
  ports {
    internal = 51413
    external = local.ports.transmission_peer
    protocol = "udp"
  }
  ports {
    internal = 9091
    external = local.ports.transmission_web
  }
  env = [
    "HOME=/root",
    "LSIO_FIRST_PARTY=true",
    "PGID=1002",
    "PS1=$(whoami)@$(hostname):$(pwd)\\$",
    "PUID=1002",
    "S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0",
    "S6_STAGE2_HOOK=/docker-mods",
    "S6_VERBOSITY=1",
    "TERM=xterm",
    "TZ=America/Sao_Paulo",
    "UMASK=022",
    "VIRTUAL_ENV=/lsiopy",
  ]
  volumes {
    volume_name    = docker_volume.vol_transmission_ro_data.name
    container_path = "/config"
    read_only      = true
  }
  volumes {
    volume_name    = docker_volume.vol_transmission_rw_data.name
    container_path = "/config_rw"
  }
  volumes {
    host_path      = "/nas/smb/Torrents"
    container_path = "/downloads"
  }
}
