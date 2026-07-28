variable "jenkins_agent_secret" {
  type      = string
  sensitive = true
}

resource "docker_image" "jenkins_agent_image" {
  name          = "jenkins/inbound-agent:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.jenkins_agent]
}

resource "docker_container" "jenkins_agent" {
  name                  = "jenkins-agent"
  image                 = docker_image.jenkins_agent_image.image_id
  restart               = "unless-stopped"
  user                  = "root:root"
  destroy_grace_seconds = 30
  init                  = true
  env = [
    "JENKINS_URL=https://jenkins.cluster.mcarvalhor.com",
    "JENKINS_SECRET=${var.jenkins_agent_secret}",
    "JENKINS_AGENT_NAME=c01",
    "JENKINS_AGENT_WORKDIR=/home/jenkins",
    "JENKINS_WEB_SOCKET=true",
  ]
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  # Backup mounts
  volumes {
    host_path      = "/var/lib/docker/volumes"
    container_path = "/hostfs/var/lib/docker/volumes"
    read_only      = true
  }
  volumes {
    host_path      = "/home"
    container_path = "/hostfs/home"
    read_only      = true
  }
  volumes {
    host_path      = "/root"
    container_path = "/hostfs/root"
    read_only      = true
  }
  volumes {
    host_path      = "/nas/nextcloud"
    container_path = "/hostfs/nas/nextcloud"
    read_only      = true
  }
}
