#!/bin/sh

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

# Protect against fork bombs
grep -Fxq "* hard nproc 10000" /etc/security/limits.conf || echo "* hard nproc 10000" >> /etc/security/limits.conf
