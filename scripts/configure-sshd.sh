#!/bin/sh

apt install -y openssh-server

# Secure SSH configuration
# sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
sed -i 's/#PrintMotd no/PrintMotd yes/' /etc/ssh/sshd_config

systemctl restart sshd
