variable "opengist_oidc" {
  type = object({
    client_key    = string
    secret        = string
    discovery_url = string
    admin_group   = string
  })

  sensitive = true

  # Enforce non-null constraints using validation blocks
  validation {
    condition     = var.opengist_oidc.client_key != null && var.opengist_oidc.secret != null && var.opengist_oidc.discovery_url != null && var.opengist_oidc.admin_group != null
    error_message = "All keys (client_key, secret, discovery_url and admin_group) must be non-null values."
  }
}

resource "docker_volume" "vol_opengist_data" {
  name = "opengist-data"
}

resource "docker_image" "opengist_image" {
  name          = "ghcr.io/thomiceli/opengist:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.opengist]
}

resource "docker_container" "opengist" {
  name    = "opengist"
  image   = docker_image.opengist_image.image_id
  restart = "unless-stopped"
  ports {
    internal = 6157
    external = local.ports.opengist
  }
  env = [
    # https://github.com/thomiceli/opengist/blob/master/docs/configuration/cheat-sheet.md
    "OG_EXTERNAL_URL=https://paste.mcarvalhor.com",
    "OG_HTTP_HOST=0.0.0.0",
    "OG_HTTP_PORT=6157",
    "OG_HTTP_GIT_ENABLED=true",
    "OG_API_ENABLED=true",
    "OG_DISABLE_FILE_UPLOAD=false",
    "OG_SSH_GIT_ENABLED=disabled",
    "OG_SSH_HOST=0.0.0.0",
    "OG_SSH_PORT=2222",
    "OG_OIDC_PROVIDER_NAME=mcarvalhor.com",
    "OG_OIDC_CLIENT_KEY=${var.opengist_oidc.client_key}",
    "OG_OIDC_SECRET=${var.opengist_oidc.secret}",
    "OG_OIDC_DISCOVERY_URL=${var.opengist_oidc.discovery_url}",
    "OG_OIDC_ADMIN_GROUP=${var.opengist_oidc.admin_group}",
    "OG_OIDC_GROUP_CLAIM_NAME=groups",
    "OG_CUSTOM_NAME=paste.mcarvalhor.com",
  ]
  volumes {
    volume_name    = docker_volume.vol_opengist_data.name
    container_path = "/opengist"
  }
}
