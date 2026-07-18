variable "nextcloud_smtp_password" {
  type = string
}

variable "nextcloud_mysql_password" {
  type = string
}

resource "docker_image" "nextcloud_image" {
  name         = "nextcloud:stable"
  keep_locally = true
}

resource "docker_container" "nextcloud" {
  name    = "nextcloud"
  image   = docker_image.nextcloud_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 80
    external = 20008
  }
  env = [
    "MYSQL_DATABASE=nextcloud",
    "MYSQL_HOST=10.1.1.1",
    "MYSQL_USER=nextcloud",
    "MYSQL_PASSWORD=${var.nextcloud_mysql_password}",
    "SMTP_HOST=smtp.sendgrid.net",
    "SMTP_SECURE=ssl",
    "SMTP_PORT=465",
    "SMTP_AUTHTYPE=LOGIN",
    "SMTP_NAME=apikey",
    "SMTP_PASSWORD=${var.nextcloud_smtp_password}",
    "MAIL_FROM_ADDRESS=admin@mcarvalhor.com",
    "MAIL_DOMAIN=mcarvalhor.com",
    "PHP_MEMORY_LIMIT=12228M",
    "PHP_UPLOAD_LIMIT=12228M",
    "NEXTCLOUD_TRUSTED_DOMAINS=cloud.mcarvalhor.com mcarvalhor.com",
    "NEXTCLOUD_INIT_HTACCESS=true",
    "OVERWRITECLIURL=https://cloud.mcarvalhor.com",
    "OVERWRITEHOST=cloud.mcarvalhor.com",
    "OVERWRITEPROTOCOL=https",
    #"TRUSTED_PROXIES=${docker_container.wireguard.network_data.ip_address} 10.0.0.0/8", # To be added after moving nginx-proxy-manager to or01.
    "PHPIZE_DEPS=autoconf 		dpkg-dev 		file 		g++ 		gcc 		libc-dev 		make 		pkg-config 		re2c",
    "PHP_INI_DIR=/usr/local/etc/php",
    "APACHE_CONFDIR=/etc/apache2",
    "APACHE_ENVVARS=/etc/apache2/envvars",
    "PHP_CFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64",
    "PHP_CPPFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64",
    "PHP_LDFLAGS=-Wl,-O1 -pie",
    "PHP_VERSION=8.2.17",
    "PHP_URL=https://www.php.net/distributions/php-8.2.17.tar.xz",
    "PHP_ASC_URL=https://www.php.net/distributions/php-8.2.17.tar.xz.asc",
    "APACHE_BODY_LIMIT=1073741824",
    "NEXTCLOUD_VERSION=28.0.3",
    "PHP_OPCACHE_MEMORY_CONSUMPTION=128",
  ]
  volumes {
    host_path      = "/nas/nextcloud"
    container_path = "/var/www/html"
  }
}
