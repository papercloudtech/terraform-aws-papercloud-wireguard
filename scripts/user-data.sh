#!/bin/bash
#
# Author: InferenceFailed Developers
# Created on: 27/12/2023
export DEBIAN_FRONTEND=noninteractive

echo -e "ec2-user@12345\nec2-user@12345" | passwd ubuntu

sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" "/etc/ssh/sshd_config"
service sshd restart

apt update && apt upgrade -y
apt install wireguard python3 python3-pip python3-virtualenv -y

private_key=$(wg genkey)

echo "$private_key" > /etc/wireguard/private.key
chmod go= /etc/wireguard/private.key
cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key

wireguard_config="[Interface]
PrivateKey = $private_key
Address = 10.0.0.0/24
ListenPort = 51820
SaveConfig = true

PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE

PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE"

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

echo "$wireguard_config" > /etc/wireguard/wg0.conf

ufw --force enable
ufw allow 51820/udp && ufw allow 22/tcp
ufw allow 80/tcp && ufw allow 443/tcp
ufw status

systemctl enable wg-quick@wg0.service && systemctl start wg-quick@wg0.service
systemctl status wg-quick@wg0.service

git clone https://${github_pat}@github.com/${github_organization}/${github_repository}.git /server/
cd /server/

virtualenv -q ./venv/ && source ./venv/bin/activate
pip3 install -r ./requirements.txt
python3 ./manage.py migrate
DJANGO_SUPERUSER_PASSWORD=ec2-user@12345 python3 ./manage.py createsuperuser --noinput --username=admin --email=admin@openkart.com
python3 ./manage.py runserver 0.0.0.0:80 > /var/log/server.log 2>&1 &
