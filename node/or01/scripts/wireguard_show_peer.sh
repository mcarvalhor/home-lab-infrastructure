#!/bin/bash

if [[ -z "${1// }" ]]; then
    echo "Please provide the peer name as argument!"
    echo "Usage: $0 PEER_NAME"
    exit 1
fi

peer_name="$1"

docker exec wireguard ls "/config/peer_${peer_name}/peer_${peer_name}.conf" 1>/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Peer '${peer_name}' not found or Wireguard down."
    exit 1
fi

echo "== Peer ${peer_name} =="
echo
echo "Config file:"
docker exec wireguard cat "/config/peer_${peer_name}/peer_${peer_name}.conf"
echo
docker exec wireguard /app/show-peer "${peer_name}"
echo