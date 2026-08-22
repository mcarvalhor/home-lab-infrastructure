variable "smtp_config" {
  type = object({
    host     = string
    port     = number
    username = string
    password = string
    domain   = string
    from_address = object({
      authentik = string
      nextcloud = string
    })
  })

  sensitive = true
}