variable "open_webui_pg_password" {
  type      = string
  sensitive = true
}

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

resource "docker_network" "open_webui" {
  name = "open-webui"
}

resource "docker_volume" "vol_open_webui_postgres" {
  name = "open-webui-postgres"
}

resource "docker_volume" "vol_open_webui_data" {
  name = "open-webui-data"
}

resource "docker_image" "open_webui_postgres_image" {
  name          = "postgres:16-alpine"
  keep_locally  = false
  pull_triggers = [local.last_deployment.open_webui_postgres]
}

resource "docker_image" "open_webui_image" {
  name          = "ghcr.io/open-webui/open-webui:main"
  keep_locally  = false
  pull_triggers = [local.last_deployment.open_webui]
}

resource "docker_container" "open_webui_postgres" {
  name                  = "open_webui_postgres"
  image                 = docker_image.open_webui_postgres_image.image_id
  restart               = "unless-stopped"
  command               = ["postgres", "-c", "max_connections=300", "-c", "shared_buffers=5GB", "-c", "effective_cache_size=16GB", "-c", "maintenance_work_mem=2GB", "-c", "work_mem=32MB"]
  destroy_grace_seconds = 30
  shm_size              = 128
  memory                = 16384
  cpus                  = "4"
  networks_advanced {
    name = docker_network.open_webui.name
  }
  env = [
    "POSTGRES_DB=open_webui",
    "POSTGRES_USER=open_webui",
    "POSTGRES_PASSWORD=${var.open_webui_pg_password}",
  ]
  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 5
    start_period = "20s"
  }
  volumes {
    volume_name    = docker_volume.vol_open_webui_postgres.name
    container_path = "/var/lib/postgresql/data"
  }
}

resource "docker_container" "open_webui" {
  name                  = "open-webui"
  image                 = docker_image.open_webui_image.image_id
  restart               = "unless-stopped"
  destroy_grace_seconds = 30
  memory                = 16384
  cpus                  = "4"
  networks_advanced {
    name = docker_network.open_webui.name
  }
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  ports {
    internal = 8080
    external = local.ports.open_webui
  }
  env = [
    "WEBUI_URL=https://ai.mcarvalhor.com",
    "CORS_ALLOW_ORIGIN=https://ai.mcarvalhor.com",
    "DATABASE_URL=postgresql+asyncpg://open_webui:${var.open_webui_pg_password}@open_webui_postgres:5432/open_webui",
    "DATABASE_POOL_SIZE=20",
    "DATABASE_POOL_MAX_OVERFLOW=30",
    "VECTOR_DB=pgvector",
    "PGVECTOR_DB_URL=postgresql://open_webui:${var.open_webui_pg_password}@open_webui_postgres:5432/open_webui",
    "DATABASE_ENABLE_SESSION_SHARING=true", # If performance goes bad, try to set it to false.
    "THREAD_POOL_SIZE=2000",
    "DATABASE_USER_ACTIVE_STATUS_UPDATE_INTERVAL=600",
    #"ENABLE_WEBSOCKET_SUPPORT=True",
    #"WEBSOCKET_MANAGER=redis",
    #"WEBSOCKET_REDIS_URL=redis://open_webui_redis:6379/0",
    #"UVICORN_WORKERS=4", # Values > 1 (default) require Redis.
    #"ENABLE_ORJSON=true",
    "ENABLE_BASE_MODELS_CACHE=true",
    "MODELS_CACHE_TTL=300",
    "ENABLE_QUERIES_CACHE=true",
    "ENABLE_REALTIME_CHAT_SAVE=false", # Never set it to true!
    "CHUNK_MIN_SIZE_TARGET=1000",      # Adjust if hurting performance.
    "CHAT_RESPONSE_STREAM_DELTA_CHUNK_SIZE=7",
    "AIOHTTP_CLIENT_TIMEOUT=1800", # Allow chatbots to respond within a 30 minutes window.
    "AIOHTTP_CLIENT_TIMEOUT_MODEL_LIST=30",
    "AIOHTTP_CLIENT_TIMEOUT_OPENAI_MODEL_LIST=30",
    "ENABLE_COMPRESSION_MIDDLEWARE=false",
    "ENABLE_PIP_INSTALL_FRONTMATTER_REQUIREMENTS=true", # Should be "false" on production environment, but might break flows if set so.
    "AUDIO_STT_ENGINE=",                                # Might hurt user experience if set to "webapi" instead of default "", although improves performance.
    "ENABLE_IMAGE_GENERATION=true",
    "ENABLE_CODE_INTERPRETER=true",
    "ENABLE_AUTOCOMPLETE_GENERATION=false", # Enabling this hurts performance.
    "ENABLE_FOLLOW_UP_GENERATION=true",
    "ENABLE_TITLE_GENERATION=true",
    "ENABLE_TAGS_GENERATION=true",
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
  volumes {
    volume_name    = docker_volume.vol_open_webui_data.name
    container_path = "/app/backend/data"
  }
}
