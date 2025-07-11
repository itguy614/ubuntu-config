#!/bin/sh

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

apt install -y fail2ban
# The cp command is missing sudo for permissions if not running as root.
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
echo "[sshd]" | sudo tee -a /etc/fail2ban/jail.local
echo "enabled = true" | sudo tee -a /etc/fail2ban/jail.local

systemctl restart fail2ban
systemctl enable fail2ban
