resource "docker_image" "php_image" {
  name          = "php:8-apache"
  keep_locally  = false
  pull_triggers = [local.last_deployment.php]
}

resource "docker_container" "php" {
  name                  = "php"
  image                 = docker_image.php_image.image_id
  restart               = "unless-stopped"
  destroy_grace_seconds = 30
  command               = ["bash", "-c", "apt update && apt install -y gettext && docker-php-ext-install gettext && a2enmod rewrite ssl && apache2-foreground"]
  ports {
    internal = 443
    external = local.ports.php_https
  }
  healthcheck {
    interval     = "1m0s"
    timeout      = "3s"
    start_period = "1m0s"
    retries      = 10
    test         = ["CMD-SHELL", "bash -c '</dev/tcp/localhost/443' || exit 1"]
  }
  volumes {
    host_path      = abspath("${path.module}/static/websites")
    container_path = "/doc_root"
    read_only      = true
  }
  volumes {
    host_path      = abspath("${path.module}/static/apache_config")
    container_path = "/etc/apache2/sites-enabled"
    read_only      = true
  }
  volumes {
    host_path      = abspath("${path.module}/static/certificates")
    container_path = "/etc/apache2/ssl"
    read_only      = true
  }
}
