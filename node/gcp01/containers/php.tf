resource "docker_image" "php_image" {
  name          = "php:8-apache"
  keep_locally  = false
  pull_triggers = [local.last_deployment.php]
}

resource "docker_container" "php" {
  name    = "php"
  image   = docker_image.php_image.image_id
  restart = "unless-stopped"
  command = ["bash", "-c", "a2enmod rewrite && echo '<Directory /doc_root>\nAllowOverride All\n</Directory>' >> /etc/apache2/apache2.conf && apache2-foreground"]
  ports {
    internal = 80
    external = local.ports.php
  }
  volumes {
    host_path      = abspath("${path.module}/static/websites")
    container_path = "/doc_root"
    read_only      = true
  }
  volumes {
    host_path      = abspath("${path.module}/static/apache_config")
    container_path = "/etc/apache2/sites-available"
    read_only      = true
  }
}
