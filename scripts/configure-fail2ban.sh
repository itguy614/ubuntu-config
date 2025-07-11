#!/bin/sh

apt install -y fail2ban

cp /etc/fail2ban/jail.{conf,local}
echo "[sshd]" >> /etc/fail2ban/jail.local
echo "enabled = true" >> /etc/fail2ban/jail.local

systemctl restart fail2ban
systemctl enable fail2ban
