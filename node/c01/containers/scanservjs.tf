resource "docker_image" "scanservjs_image" {
  name         = "sbs20/scanservjs:latest"
  keep_locally = true
}

resource "docker_volume" "vol_scanservjs_data" {
  name = "scanservjs_data"
}

resource "docker_container" "scanservjs" {
  name       = "scanservjs"
  image      = docker_image.scanservjs_image.image_id
  restart    = "unless-stopped"
  privileged = true
  devices {
    host_path      = "/dev/bus/usb"
    container_path = "/dev/bus/usb"
  }
  ports {
    internal = 8080
    external = local.ports.scanservjs
  }
  env = [
    "AIRSCAN_DEVICES=",
    "DEVICES=",
    "OCR_LANG=",
    "SANED_NET_HOSTS=c01",
    "SCANIMAGE_LIST_IGNORE=",
    "PIXMA_HOSTS=",
  ]
  volumes {
    host_path      = "/var/run/dbus"
    container_path = "/var/run/dbus"
    read_only      = true
  }
  volumes {
    volume_name    = docker_volume.vol_scanservjs_data.name
    container_path = "/app/config"
    read_only      = true
  }
}
