#!/bin/bash
#
# Author: InferenceFailed Developers
# Created on: 27/12/2023
usage() {
  echo "Usage: $0 -c client_ip -s server_ip [-d dns] [-p tunnel_port]"
  exit 1
}

serverpubkey() {
  cat /etc/wireguard/public.key
}

keygen() {
  local client_private_key=$(wg genkey)

  mkdir -p $workdir

  echo "$client_private_key" > $workdir/private.key
  chmod go= $workdir/private.key

  cat $workdir/private.key | wg pubkey > $workdir/public.key
}

confgen() {
  local client_config="[Interface]
PrivateKey = $1
Address = $2/32
DNS = $3

[Peer]
PublicKey = $4
AllowedIPs = 0.0.0.0/0
Endpoint = $5:$6"

  echo "$client_config" > $workdir/client.conf
}

dns="1.1.1.1,1.1.0.0"
tunnel_port=51820

while getopts ":c:s:pdh" opt; do
  case $opt in
    c)
      client_ip="$OPTARG"
      ;;
    d)
      dns="$OPTARG"
      ;;
    p)
      tunnel_port="$OPTARG"
      ;;
    s)
      server_ip="$OPTARG"
      ;;
    h)
      usage
      ;;
    \?)
      echo "Invalid option provided: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option '-$OPTARG' requires an argument." >&2
      usage
      ;;
  esac
done

workdir=/etc/wireguard/clients/$client_ip

keygen
confgen "$(cat $workdir/private.key)" "$client_ip" "$dns" "$(serverpubkey)" "$server_ip" "$tunnel_port"

wg set wg0 peer $(cat $workdir/public.key) allowed-ips $client_ip
