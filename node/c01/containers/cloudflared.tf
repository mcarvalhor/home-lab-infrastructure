variable "cloudflared_token" {
  type      = string
  sensitive = true
}

resource "docker_image" "cloudflared_image" {
  name          = "cloudflare/cloudflared:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.cloudflared]
}

resource "docker_container" "cloudflared" {
  name                  = "cloudflared"
  image                 = docker_image.cloudflared_image.image_id
  restart               = "unless-stopped"
  destroy_grace_seconds = 30
  command               = ["tunnel", "--no-autoupdate", "run", "--token", "${var.cloudflared_token}"]
}
