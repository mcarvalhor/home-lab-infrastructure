resource "docker_image" "nginx_torrent_dl_image" {
  name          = "httpd:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.nginx_torrent_dl]
}

resource "docker_container" "nginx_torrent_dl" {
  name                  = "nginx_torrent-dl"
  image                 = docker_image.nginx_torrent_dl_image.image_id
  restart               = "unless-stopped"
  destroy_grace_seconds = 30
  command               = ["bash", "-c", "echo >> /usr/local/apache2/conf/httpd.conf && echo 'IndexOptions +Charset=UTF-8' >> /usr/local/apache2/conf/httpd.conf && httpd-foreground"]
  ports {
    internal = 80
    external = local.ports.nginx_torrent_dl
  }
  volumes {
    host_path      = "/nas/smb/Torrents"
    container_path = "/usr/local/apache2/htdocs"
    read_only      = true
  }
}
