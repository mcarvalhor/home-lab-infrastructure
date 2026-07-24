locals {
  ports = {
    # Application UIs (proxied, 200xx range).
    zabbix_web       = 20001
    jenkins          = 20002
    phpmyadmin       = 20003
    transmission_web = 20004
    plex             = 20005
    handbrake        = 20006
    scanservjs       = 20007
    nextcloud        = 20008
    authentik_http   = 20009
    nginx_torrent_dl = 20010
    opengist         = 20011
    kutt             = 20012

    # Protocol-specific ports kept at their native number.
    portainer         = 9443
    portainer_agent   = 9001
    zabbix_server     = 10051
    teamspeak_query   = 10011
    teamspeak_filexfr = 30033
    teamspeak_voice   = 9987
    transmission_peer = 51413
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
