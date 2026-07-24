variable "kutt_oidc" {
  type = object({
    client_id     = string
    client_secret = string
    issuer        = string
  })

  sensitive = true

  # Enforce non-null constraints using validation blocks
  validation {
    condition     = var.kutt_oidc.client_id != null && var.kutt_oidc.client_secret != null && var.kutt_oidc.issuer != null
    error_message = "All keys (client_id, client_secret and issuer) must be non-null values."
  }
}

resource "docker_volume" "vol_kutt_data" {
  name = "kutt-data"
}

resource "docker_image" "kutt_image" {
  name          = "kutt/kutt:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.kutt]
}

resource "docker_container" "kutt" {
  name    = "kutt"
  image   = docker_image.kutt_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 3000
    external = local.ports.kutt
  }
  env = [
    "PORT=3000",
    "SITE_NAME=url.mcarvalhor.com",
    "DEFAULT_DOMAIN=url.mcarvalhor.com",
    "LINK_LENGTH=6",
    "DISALLOW_REGISTRATION=true",
    "DISALLOW_LOGIN_FORM=true",
    "DISALLOW_ANONYMOUS_LINKS=true",
    "TRUST_PROXY=true",
    "DB_CLIENT=better-sqlite3",
    "DB_FILENAME=/var/lib/kutt/db/data",
    "CUSTOM_DOMAIN_USE_HTTPS=true",
    "OIDC_ENABLED=true",
    "OIDC_ISSUER=${var.kutt_oidc.issuer}",
    "OIDC_CLIENT_ID=${var.kutt_oidc.client_id}",
    "OIDC_CLIENT_SECRET=${var.kutt_oidc.client_secret}",
    "OIDC_SCOPE=openid profile email",
    "OIDC_EMAIL_CLAIM=email",
    "OIDC_BUTTON_TEXT=Log in with mcarvalhor.com",
  ]
  volumes {
    volume_name    = docker_volume.vol_kutt_data.name
    container_path = "/var/lib/kutt"
  }
}
