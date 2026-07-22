resource "docker_image" "mariadb_image" {
  name          = "mariadb:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.mariadb]
}

resource "docker_volume" "vol_mariadb_data" {
  name = "mariadb_data"
}

resource "docker_container" "mariadb" {
  name         = "mariadb"
  image        = docker_image.mariadb_image.image_id
  restart      = "unless-stopped"
  network_mode = "host"
  env = [
    "GOSU_VERSION=1.14",
    "LANG=C.UTF-8",
    "MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes",
    "MARIADB_AUTO_UPGRADE=yes",
    "MARIADB_MYSQL_LOCALHOST_USER=yes",
    "MARIADB_ROOT_HOST=localhost",
    "MARIADB_VERSION=1:10.10.2+maria~ubu2204",
  ]
  volumes {
    volume_name    = docker_volume.vol_mariadb_data.name
    container_path = "/var/lib/mysql"
  }
}
