#!/bin/sh

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

apt remove --purge -y ufw

iptables -F
iptables -X

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related traffic
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow SNMP
iptables -A INPUT -p udp --dport 161 -j ACCEPT

# Allow ICMP echo requests (ping)
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

# Allow multicast UDP traffic
iptables -A INPUT -p udp -d 224.0.0.0/4 -j ACCEPT
iptables -A OUTPUT -p udp -d 224.0.0.0/4 -j ACCEPT

# Allow IGMP
iptables -A INPUT -p igmp -d 224.0.0.0/4 -j ACCEPT
iptables -A OUTPUT -p igmp -d 224.0.0.0/4 -j ACCEPT
