resource "docker_image" "nginx_torrent_dl_image" {
  name         = "httpd:latest"
  keep_locally = true
  pull_triggers = [ local.last_deployment.nginx_torrent_dl ]
}

resource "docker_container" "nginx_torrent_dl" {
  name    = "nginx_torrent-dl"
  image   = docker_image.nginx_torrent_dl_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 80
    external = local.ports.nginx_torrent_dl
  }
  env = [
    "HTTPD_PREFIX=/usr/local/apache2",
    "HTTPD_VERSION=2.4.57",
    "HTTPD_SHA256=dbccb84aee95e095edfbb81e5eb926ccd24e6ada55dcd83caecb262e5cf94d2a",
    "HTTPD_PATCHES=rewrite-windows-testchar-h.patch 1d5620574fa03b483262dc5b9a66a6906553389952ab5d3070a02f887cc20193",
  ]
  volumes {
    host_path      = "/nas/smb/Torrents"
    container_path = "/usr/local/apache2/htdocs"
    read_only      = true
  }
}
