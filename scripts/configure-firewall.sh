#!/bin/sh

apt install -y ufw

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh/tcp
ufw enable
systemctl start ufw
systemctl enable ufw
