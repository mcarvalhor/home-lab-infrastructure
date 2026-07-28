resource "docker_volume" "vol_open_webui_data" {
  name = "open-webui-data"
}

resource "docker_image" "open_webui_image" {
  name          = "ghcr.io/open-webui/open-webui:main"
  keep_locally  = false
  pull_triggers = [local.last_deployment.open_webui]
}

resource "docker_container" "open_webui" {
  name                  = "open-webui"
  image                 = docker_image.open_webui_image.image_id
  restart               = "unless-stopped"
  destroy_grace_seconds = 30
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  ports {
    internal = 8080
    external = local.ports.open_webui
  }
  volumes {
    volume_name    = docker_volume.vol_open_webui_data.name
    container_path = "/app/backend/data"
  }
}
