#!/bin/sh

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

apt install -y openssh-server

# Secure SSH configuration
# sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
sed -i 's/#PrintMotd no/PrintMotd yes/' /etc/ssh/sshd_config

if grep -q "^#Banner" /etc/ssh/sshd_config; then
    sed -i 's|^#Banner.*|Banner /etc/issue.net|' /etc/ssh/sshd_config
elif ! grep -q "^Banner" /etc/ssh/sshd_config; then
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
fi

systemctl restart sshd
