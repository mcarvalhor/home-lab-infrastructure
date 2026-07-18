resource "docker_image" "teamspeak_image" {
  name         = "teamspeak:latest"
  keep_locally = true
}

resource "docker_volume" "vol_teamspeak_data" {
  name = "teamspeak_data"
}

resource "docker_container" "teamspeak" {
  name    = "teamspeak"
  image   = docker_image.teamspeak_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 10011
    external = local.ports.teamspeak_query
  }
  ports {
    internal = 30033
    external = local.ports.teamspeak_filexfr
  }
  ports {
    internal = 9987
    external = local.ports.teamspeak_voice
    protocol = "udp"
  }
  env = [
    "TS3SERVER_LICENSE=accept",
    "TS3SERVER_FILETRANSFER_PORT=30033",
  ]
  volumes {
    volume_name    = docker_volume.vol_teamspeak_data.name
    container_path = "/var/ts3server"
  }
}
