#!/bin/sh

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

# Harden cron jobs
chmod 750 /etc/crontab
chmod 750 /etc/cron.hourly
chmod 750 /etc/cron.daily
chmod 750 /etc/cron.weekly
chmod 750 /etc/cron.monthly
chmod 750 /etc/cron.d
