variable "authentik_pg_password" {
  type = string
}

variable "authentik_secret_key" {
  type = string
}

resource "docker_network" "authentik" {
  name = "authentik"
}

resource "docker_volume" "vol_authentik_postgres" {
  name = "authentik_postgres"
}

resource "docker_volume" "vol_authentik_data" {
  name = "authentik_data"
}

resource "docker_volume" "vol_authentik_certs" {
  name = "authentik_certs"
}

resource "docker_volume" "vol_authentik_custom_templates" {
  name = "authentik_custom_templates"
}

resource "docker_image" "authentik_postgres_image" {
  name         = "postgres:latest"
  keep_locally = true
}

resource "docker_image" "authentik_server_image" {
  name         = "authentik/server:2026.5"
  keep_locally = true
}

resource "docker_container" "authentik_postgres" {
  name    = "authentik_postgres"
  image   = docker_image.authentik_postgres_image.image_id
  restart = "unless-stopped"
  networks_advanced {
    name    = docker_network.authentik.name
  }
  env = [
    "POSTGRES_DB=authentik",
    "POSTGRES_USER=authentik",
    "POSTGRES_PASSWORD=${var.authentik_pg_password}",
  ]
  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 5
    start_period = "20s"
  }
  volumes {
    volume_name    = docker_volume.vol_authentik_postgres.name
    container_path = "/var/lib/postgresql/data"
  }
}

resource "docker_container" "authentik_server" {
  name       = "authentik_server"
  image      = docker_image.authentik_server_image.image_id
  restart    = "unless-stopped"
  command    = ["server"]
  shm_size   = 512
  depends_on = [docker_container.authentik_postgres]
  networks_advanced {
    name = docker_network.authentik.name
  }
  ports {
    internal = 9000
    external = local.ports.authentik_http
  }
  env = [
    "AUTHENTIK_POSTGRESQL__HOST=authentic_postgresql",
    "AUTHENTIK_POSTGRESQL__NAME=authentik",
    "AUTHENTIK_POSTGRESQL__USER=authentik",
    "AUTHENTIK_POSTGRESQL__PASSWORD=${var.authentik_pg_password}",
    "AUTHENTIK_SECRET_KEY=${var.authentik_secret_key}",
  ]
  volumes {
    volume_name    = docker_volume.vol_authentik_data.name
    container_path = "/data"
  }
  volumes {
    volume_name    = docker_volume.vol_authentik_custom_templates.name
    container_path = "/templates"
  }
}

resource "docker_container" "authentik_worker" {
  name       = "authentik_worker"
  image      = docker_image.authentik_server_image.image_id
  restart    = "unless-stopped"
  command    = ["worker"]
  shm_size   = 512
  user       = "root"
  depends_on = [docker_container.authentik_postgres]
  networks_advanced {
    name = docker_network.authentik.name
  }
  env = [
    "AUTHENTIK_POSTGRESQL__HOST=authentic_postgresql",
    "AUTHENTIK_POSTGRESQL__NAME=authentik",
    "AUTHENTIK_POSTGRESQL__USER=authentik",
    "AUTHENTIK_POSTGRESQL__PASSWORD=${var.authentik_pg_password}",
    "AUTHENTIK_SECRET_KEY=${var.authentik_secret_key}",
  ]
  volumes {
    volume_name    = docker_volume.vol_authentik_data.name
    container_path = "/data"
  }
  volumes {
    volume_name    = docker_volume.vol_authentik_certs.name
    container_path = "/certs"
  }
  volumes {
    volume_name    = docker_volume.vol_authentik_custom_templates.name
    container_path = "/templates"
  }
}
