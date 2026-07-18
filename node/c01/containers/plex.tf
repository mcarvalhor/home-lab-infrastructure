variable "plex_claim" {
  type = string
}

resource "docker_image" "plex_image" {
  name         = "linuxserver/plex:latest"
  keep_locally = true
}

resource "docker_volume" "vol_plex_data" {
  name = "plex_data"
}

resource "docker_container" "plex" {
  name    = "plex"
  image   = docker_image.plex_image.image_id
  restart = "unless-stopped"
  devices {
    host_path      = "/dev/dri"
    container_path = "/dev/dri"
  }
  ports {
    internal = 32400
    external = local.ports.plex
  }
  env = [
    "DEBIAN_FRONTEND=noninteractive",
    "HOME=/root",
    "LANG=en_US.UTF-8",
    "LANGUAGE=en_US.UTF-8",
    "LSIO_FIRST_PARTY=true",
    "NVIDIA_DRIVER_CAPABILITIES=compute,video,utility",
    "PGID=1002",
    "PLEX_ARCH=amd64",
    "PLEX_CLAIM=${var.plex_claim}",
    "PLEX_DOWNLOAD=https://downloads.plex.tv/plex-media-server-new",
    "PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/config/Library/Application Support",
    "PLEX_MEDIA_SERVER_HOME=/usr/lib/plexmediaserver",
    "PLEX_MEDIA_SERVER_INFO_DEVICE=Docker Container (LinuxServer.io)",
    "PLEX_MEDIA_SERVER_INFO_VENDOR=Docker",
    "PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6",
    "PLEX_MEDIA_SERVER_USER=abc",
    "PUID=1002",
    "S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0",
    "S6_STAGE2_HOOK=/docker-mods",
    "S6_VERBOSITY=1",
    "TERM=xterm",
    "UMASK=022",
    "VERSION=docker",
    "VIRTUAL_ENV=/lsiopy",
    "TMPDIR=/run/plex-temp",
    "ATTACHED_DEVICES_PERMS=/dev/dri /dev/dvb -type c",
  ]
  volumes {
    volume_name    = docker_volume.vol_plex_data.name
    container_path = "/config"
  }
  volumes {
    host_path      = "/nas/smb/Plex"
    container_path = "/media"
  }
}
