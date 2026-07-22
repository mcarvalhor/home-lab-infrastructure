resource "docker_image" "jenkins_image" {
  name          = "jenkins/jenkins:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.jenkins]
}

resource "docker_volume" "vol_jenkins_data" {
  name = "jenkins_data"
}

resource "docker_container" "jenkins" {
  name    = "jenkins"
  image   = docker_image.jenkins_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 8080
    external = local.ports.jenkins
  }
  env = [
    "COPY_REFERENCE_FILE_LOG=/var/jenkins_home/copy_reference_file.log",
    "JAVA_HOME=/opt/java/openjdk",
    "JAVA_OPTS=-Dhudson.footerURL=https://mcarvalhor.com",
    "JENKINS_HOME=/var/jenkins_home",
    "JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals",
    "JENKINS_SLAVE_AGENT_PORT=50000",
    "JENKINS_UC=https://updates.jenkins.io",
    "JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental",
    "LANG=C.UTF-8",
    "REF=/usr/share/jenkins/ref",
    "JENKINS_VERSION=2.504",
  ]
  volumes {
    host_path      = "/nas"
    container_path = "/nas"
    read_only      = true
  }
  volumes {
    volume_name    = docker_volume.vol_jenkins_data.name
    container_path = "/var/jenkins_home"
  }
}
