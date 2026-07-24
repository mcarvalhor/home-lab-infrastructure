resource "docker_image" "portainer_agent_image" {
  name          = "portainer/agent:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.portainer_agent]
}

resource "docker_container" "portainer_agent" {
  name    = "portainer-agent"
  image   = docker_image.portainer_agent_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 9001
    external = local.ports.portainer_agent
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  volumes {
    host_path      = "/var/lib/docker/volumes"
    container_path = "/var/lib/docker/volumes"
  }
}
