variable "open_webui_oidc" {
  type = object({
    client_id            = string
    client_secret        = string
    provider_url         = string
    redirect_uri         = string
    end_session_endpoint = string
    scopes               = string
  })

  sensitive = true

  # Enforce non-null constraints using validation blocks
  validation {
    condition     = var.open_webui_oidc.client_id != null && var.open_webui_oidc.client_secret != null && var.open_webui_oidc.provider_url != null && var.open_webui_oidc.redirect_uri != null && var.open_webui_oidc.end_session_endpoint != null && var.open_webui_oidc.scopes != null
    error_message = "All keys (client_id, client_secret, provider_url, redirect_uri, end_session_endpoint and scopes) must be non-null values."
  }
}

resource "docker_volume" "vol_open_webui_data" {
  name = "open-webui-data"
}

resource "docker_image" "open_webui_image" {
  name          = "ghcr.io/open-webui/open-webui:main"
  keep_locally  = false
  pull_triggers = [local.last_deployment.open_webui]
}

resource "docker_container" "open_webui" {
  name                  = "open-webui"
  image                 = docker_image.open_webui_image.image_id
  restart               = "unless-stopped"
  destroy_grace_seconds = 30
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  env = [
    "WEBUI_URL=https://ai.mcarvalhor.com",
    "ENABLE_PERSISTENT_CONFIG=true",
    "ENABLE_OAUTH_PERSISTENT_CONFIG=false",
    "BYPASS_MODEL_ACCESS_CONTROL=true",
    "ENABLE_OAUTH=true",
    "ENABLE_OAUTH_SIGNUP=true",
    "ENABLE_PASSWORD_AUTH=false",
    "ENABLE_SIGNUP=false",
    "OAUTH_AUTO_REDIRECT=false",
    "ENABLE_LOGIN_FORM=false",
    "OAUTH_MERGE_ACCOUNTS_BY_EMAIL=true",
    "OAUTH_UPDATE_PICTURE_ON_LOGIN=true",
    "ENABLE_OAUTH_BACKCHANNEL_LOGOUT=true",
    "OPENID_END_SESSION_ENDPOINT=${var.open_webui_oidc.end_session_endpoint}",
    "OAUTH_CLIENT_ID=${var.open_webui_oidc.client_id}",
    "OAUTH_CLIENT_SECRET=${var.open_webui_oidc.client_secret}",
    "OPENID_PROVIDER_URL=${var.open_webui_oidc.provider_url}",
    "OPENID_REDIRECT_URI=${var.open_webui_oidc.redirect_uri}",
    "OAUTH_SCOPES=${var.open_webui_oidc.scopes}",
    "OAUTH_PROVIDER_NAME=auth.mcarvalhor.com",
    "ENABLE_OAUTH_ROLE_MANAGEMENT=true",
    "OAUTH_ROLES_CLAIM=groups",
    "OAUTH_ALLOWED_ROLES=OpenWebUI,authentik Admins",
    "OAUTH_ADMIN_ROLES=authentik Admins",

  ]
  ports {
    internal = 8080
    external = local.ports.open_webui
  }
  volumes {
    volume_name    = docker_volume.vol_open_webui_data.name
    container_path = "/app/backend/data"
  }
}
