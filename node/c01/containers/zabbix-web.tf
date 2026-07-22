resource "docker_image" "zabbix_web_image" {
  name          = "zabbix/zabbix-web-nginx-mysql:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.zabbix_web]
}

resource "docker_container" "zabbix_web" {
  name    = "zabbix-web"
  image   = docker_image.zabbix_web_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 8080
    external = local.ports.zabbix_web
  }
  env = [
    "DB_SERVER_HOST=10.1.1.1",
    "DB_SERVER_PORT=3306",
    "MYSQL_DATABASE=zabbix",
    "MYSQL_PASSWORD=${var.zabbix_mysql_password}",
    "MYSQL_USER=zabbix",
    "PHP_TZ=America/Sao_Paulo",
    "TERM=xterm",
    "ZBX_SERVER_HOST=10.1.1.1",
    "ZBX_SERVER_NAME=cluster.mcarvalhor.com",
    "ZBX_SERVER_PORT=10051",
    "ZBX_SOURCES=https://git.zabbix.com/scm/zbx/zabbix.git",
    "ZBX_VERSION=6.2.6",
    "ZABBIX_CONF_DIR=/etc/zabbix",
    "ZABBIX_WWW_ROOT=/usr/share/zabbix",
    "ZABBIX_USER_HOME_DIR=/var/lib/zabbix",
  ]
  entrypoint = ["docker-entrypoint.sh"]
}
