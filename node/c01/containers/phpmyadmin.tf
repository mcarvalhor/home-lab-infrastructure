resource "docker_image" "phpmyadmin_image" {
  name          = "phpmyadmin:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.phpmyadmin]
}

resource "docker_container" "phpmyadmin" {
  name    = "phpmyadmin"
  image   = docker_image.phpmyadmin_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 80
    external = local.ports.phpmyadmin
  }
  env = [
    "APACHE_CONFDIR=/etc/apache2",
    "APACHE_ENVVARS=/etc/apache2/envvars",
    "HIDE_PHP_VERSION=true",
    "MAX_EXECUTION_TIME=3600",
    "MEMORY_LIMIT=12228M",
    "PHP_ASC_URL=https://www.php.net/distributions/php-8.0.26.tar.xz.asc",
    "PHP_CFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64",
    "PHP_CPPFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64",
    "PHP_INI_DIR=/usr/local/etc/php",
    "PHP_LDFLAGS=-Wl,-O1 -pie",
    "PHP_URL=https://www.php.net/distributions/php-8.0.26.tar.xz",
    "PHP_VERSION=8.0.26",
    "PHPIZE_DEPS=autoconf 		dpkg-dev 		file 		g++ 		gcc 		libc-dev 		make 		pkg-config 		re2c",
    "PMA_ARBITRARY=0",
    "PMA_HOST=10.1.1.1",
    "PMA_PORT=3306",
    "TZ=UTC",
    "UPLOAD_LIMIT=12228M",
    "URL=https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.tar.xz",
    "VERSION=5.2.0",
    "SESSION_SAVE_PATH=/sessions",
    "PMA_SSL_DIR=/etc/phpmyadmin/ssl",
  ]
}
