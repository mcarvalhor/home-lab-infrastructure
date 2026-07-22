resource "docker_image" "portainer_image" {
  name         = "portainer/portainer-ce:latest"
  keep_locally = true
  pull_triggers = [ local.last_deployment.portainer ]
}

resource "docker_volume" "vol_portainer_data" {
  name = "portainer_data"
}

resource "docker_container" "portainer" {
  name    = "portainer"
  image   = docker_image.portainer_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 9443
    external = local.ports.portainer
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  volumes {
    volume_name    = docker_volume.vol_portainer_data.name
    container_path = "/data"
  }
}
