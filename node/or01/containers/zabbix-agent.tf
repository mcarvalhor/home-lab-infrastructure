resource "docker_image" "zabbix_agent_image" {
  name          = "zabbix/zabbix-agent2:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.zabbix_agent]
}

resource "docker_container" "zabbix_agent" {
  name         = "zabbix-agent"
  image        = docker_image.zabbix_agent_image.image_id
  restart      = "unless-stopped"
  user         = "root:root"
  network_mode = "host"
  pid_mode     = "host"
  ipc_mode     = "host"
  privileged   = true
  init         = true
  env = [
    "ZBX_HOSTNAME=or01",
    "ZBX_SERVER_HOST=10.2.0.2",
    "ZBX_LISTENIP=0.0.0.0",
    "ZBX_LISTENPORT=${local.ports.zabbix_agent}",
  ]
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  volumes {
    host_path      = "/var/run/dbus"
    container_path = "/var/run/dbus"
    read_only      = true
  }
  volumes {
    host_path      = "/"
    container_path = "/hostfs"
    read_only      = true
  }
  volumes {
    host_path      = "/etc/timezone"
    container_path = "/etc/timezone"
    read_only      = true
  }
  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }
}
