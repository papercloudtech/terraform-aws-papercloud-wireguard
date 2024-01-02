#!/bin/bash
#
# Author: InferenceFailed Developers
# Created on: 02/01/2024
usage() {
  echo "Usage: $0 -c client_ip [-i interface_name=wg0]"
}

interface_name="wg0"

while getopts ":c:i:h" opt; do
  case $opt in
    c)
      public_key="$OPTARG"
      ;;
    i)
      interface_name="$OPTARG"
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Invalid option provided: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Option '-$OPTARG' requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

workdir=/etc/wireguard/clients/$client_ip

wg set $interface_name peer $(cat $workdir/public.key) remove
rm -r $workdir
