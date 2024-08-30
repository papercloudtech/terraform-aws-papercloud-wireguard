#!/bin/bash
#
# Author: PaperCloud Developers
# Created on: 27/12/2023
export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade -y
apt install wireguard python3 python3-pip python3-virtualenv -y

private_key=$(wg genkey)

echo "$private_key" > /etc/wireguard/private.key
chmod go= /etc/wireguard/private.key
cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key

wireguard_config="[Interface]
PrivateKey = $private_key
Address = 10.0.0.1/24
ListenPort = 51820
SaveConfig = true

PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE"

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

echo "$wireguard_config" > /etc/wireguard/wg0.conf

systemctl enable wg-quick@wg0.service && systemctl start wg-quick@wg0.service
systemctl status wg-quick@wg0.service

echo "[Unit]
Description=WireGuard Web App Server
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/server
ExecStart=/server/venv/bin/python3 /server/manage.py runserver 0.0.0.0:80
Restart=always

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/django.service

systemctl daemon-reload
systemctl enable --now django.service
systemctl status django.service

git clone https://github.com/${github_organization}/${github_repository}.git /server/
cd /server/

virtualenv -q ./venv/ && source ./venv/bin/activate
pip3 install -r ./requirements.txt

python3 ./manage.py makemigrations api
python3 ./manage.py migrate
DJANGO_SUPERUSER_PASSWORD=ec2-user@12345 python3 ./manage.py createsuperuser --noinput --username=admin --email=test-admin@papercloud.tech
python3 ./manage.py runserver 0.0.0.0:80 > /var/log/server.log 2>&1 &
