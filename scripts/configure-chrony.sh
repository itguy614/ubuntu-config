#!/bin/sh

# Install chrony and configure NTP
apt install -y chrony
sed -i 's/^pool.*/pool 0.centos.pool.ntp.org iburst/' /etc/chrony/chrony.conf
sed -i 's/^server.*/server 0.centos.pool.ntp.org iburst/' /etc/chrony/chrony.conf
systemctl enable chronyd
systemctl start chronyd
