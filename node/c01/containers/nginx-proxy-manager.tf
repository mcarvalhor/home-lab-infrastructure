resource "docker_image" "nginx_proxy_manager_image" {
  name         = "jc21/nginx-proxy-manager:latest"
  keep_locally = true
}

resource "docker_volume" "vol_nginx_proxy_manager_data" {
  name = "nginx-proxy-manager_data"
}

resource "docker_container" "nginx_proxy_manager" {
  name         = "nginx-proxy-manager"
  image        = docker_image.nginx_proxy_manager_image.image_id
  restart      = "unless-stopped"
  network_mode = "host"
  env = [
    "DB_SQLITE_FILE=/data/database.sqlite",
    "X_FRAME_OPTIONS=sameorigin",
    "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt",
    "CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt",
    "SUPPRESS_NO_CONFIG_WARNING=1",
    "S6_BEHAVIOUR_IF_STAGE2_FAILS=1",
    "S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0",
    "S6_FIX_ATTRS_HIDDEN=1",
    "S6_KILL_FINISH_MAXTIME=10000",
    "S6_VERBOSITY=1",
  ]
  volumes {
    volume_name    = docker_volume.vol_nginx_proxy_manager_data.name
    container_path = "/etc/letsencrypt"
  }
  volumes {
    volume_name    = docker_volume.vol_nginx_proxy_manager_data.name
    container_path = "/data"
  }
}
