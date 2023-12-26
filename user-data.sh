#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo -e "ec2-user@12345\nec2-user@12345" | passwd ubuntu

sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" "/etc/ssh/sshd_config"
service sshd restart

apt update && apt upgrade -y
apt install wireguard -y

private_key=$(wg genkey)

echo "$private_key" >> sudo tee /etc/wireguard/private.key
chmod go= /etc/wireguard/private.key
cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key

wireguard_config="[Interface]
PrivateKey = $private_key
Address = 10.8.0.1/24
ListenPort = 51820
SaveConfig = true

PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE

PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE"

echo "net.ipv4.ip_forward = 1" | tee -a /etc/sysctl.conf
sysctl -p

ufw --force enable
ufw allow 51820/udp && ufw allow 22/tcp
ufw status

systemctl enable wg-quick@wg0.service && systemctl start wg-quick@wg0.service
systemctl status wg-quick@wg0.service
