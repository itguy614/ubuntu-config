#!/bin/sh

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

apt install -y ufw

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh/tcp

# Allow snmp
ufw allow 161/udp

# Allow ICMP echo requests (ping)
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

## Allow multicast traffic
ufw allow in proto udp to 224.0.0.0/4
ufw allow in proto udp from 224.0.0.0/4


ufw enable
systemctl start ufw
systemctl enable ufw
