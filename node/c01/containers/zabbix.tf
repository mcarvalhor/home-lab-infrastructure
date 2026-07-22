variable "zabbix_mysql_password" {
  type      = string
  sensitive = true
}

resource "docker_image" "zabbix_server_image" {
  name          = "zabbix/zabbix-server-mysql:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.zabbix_server]
}

resource "docker_image" "zabbix_web_image" {
  name          = "zabbix/zabbix-web-nginx-mysql:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.zabbix_web]
}

resource "docker_container" "zabbix_server" {
  name    = "zabbix-server"
  image   = docker_image.zabbix_server_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 10051
    external = local.ports.zabbix_server
  }
  env = [
    "DB_SERVER_HOST=10.1.1.1",
    "DB_SERVER_PORT=3306",
    "MYSQL_DATABASE=zabbix",
    "MYSQL_PASSWORD=${var.zabbix_mysql_password}",
    "MYSQL_USER=zabbix",
    "ZBX_ALLOWUNSUPPORTEDDBVERSIONS=1",
    "ZBX_JAVAGATEWAY_ENABLE=true",
    "NMAP_PRIVILEGED=",
    "TERM=xterm",
    "ZBX_VERSION=7.0.0",
    "ZBX_SOURCES=https://git.zabbix.com/scm/zbx/zabbix.git",
    "MIBDIRS=/usr/share/snmp/mibs:/var/lib/zabbix/mibs",
    "MIBS=+ALL",
    "ZABBIX_USER_HOME_DIR=/var/lib/zabbix",
    "ZABBIX_CONF_DIR=/etc/zabbix",
    "ZBX_DB_NAME=dummy_db_name",
    "ZBX_FPINGLOCATION=/usr/sbin/fping",
    "ZBX_LOADMODULEPATH=/var/lib/zabbix/modules",
    "ZBX_SNMPTRAPPERFILE=/var/lib/zabbix/snmptraps/snmptraps.log",
    "ZBX_SSHKEYLOCATION=/var/lib/zabbix/ssh_keys/",
    "ZBX_SSLCERTLOCATION=/var/lib/zabbix/ssl/certs/",
    "ZBX_SSLKEYLOCATION=/var/lib/zabbix/ssl/keys/",
    "ZBX_SSLCALOCATION=/var/lib/zabbix/ssl/ssl_ca/",
    "MARIADB_TLS_DISABLE_PEER_VERIFICATION=1",
  ]
  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }
  volumes {
    host_path      = "/etc/timezone"
    container_path = "/etc/timezone"
    read_only      = true
  }
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