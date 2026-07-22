variable "wireguard_client_keys" {
  type = object({
    private_key   = string
    public_key    = string
    preshared_key = string
  })

  sensitive = true

  # Enforce non-null constraints using validation blocks
  validation {
    condition     = var.wireguard_client_keys.private_key != null && var.wireguard_client_keys.public_key != null && var.wireguard_client_keys.preshared_key != null
    error_message = "All keys (private_key, public_key, and preshared_key) must be non-null values."
  }
}

resource "local_sensitive_file" "wireguard_client_conf_file" {
  filename = abspath("${path.module}/configs/wireguard-client.wg.conf")

  # Render the template and pass variables into it
  content = templatefile(abspath("${path.module}/configs/wireguard-client_conf.tftpl"), {
    private_key   = var.wireguard_client_keys.private_key
    public_key    = var.wireguard_client_keys.public_key
    preshared_key = var.wireguard_client_keys.preshared_key
  })
}

resource "docker_image" "wireguard_client_image" {
  name          = "linuxserver/wireguard:latest"
  keep_locally  = false
  pull_triggers = [local.last_deployment.wireguard]
}

resource "docker_container" "wireguard_client" {
  name         = "wireguard-client"
  image        = docker_image.wireguard_client_image.image_id
  restart      = "unless-stopped"
  network_mode = "host"
  capabilities {
    add = ["CAP_NET_ADMIN", "CAP_SYS_MODULE"]
  }
  volumes {
    host_path      = abspath("${path.root}/configs/wireguard-client.conf")
    container_path = "/config/wg0.conf"
    read_only      = true
  }
  volumes {
    host_path      = abspath("${path.root}/configs/wireguard-client.conf")
    container_path = "/config/wg_confs/wg0.conf"
    read_only      = true
  }
  volumes {
    host_path      = "/lib/modules"
    container_path = "/lib/modules"
    read_only      = true
  }
  lifecycle {
    replace_triggered_by = [
      local_sensitive_file.wireguard_client_conf_file
    ]
  }
}
