#!/bin/sh

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

# Configure automatic security updates
apt install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades
