locals {
  ports = {
    # Application UIs (proxied, 200xx range).

    # Protocol-specific ports kept at their native number.
    portainer_agent = 9001
    zabbix_agent    = 10050
    wireguard_vpn   = 51820
    wireguard_web   = 51821
  }
}

# Fail the plan early if two services are ever assigned the same external port.
check "unique_ports" {
  assert {
    condition     = length(values(local.ports)) == length(distinct(values(local.ports)))
    error_message = "Duplicate external port detected in local.ports."
  }
}

output "published_ports" {
  value = local.ports
}
