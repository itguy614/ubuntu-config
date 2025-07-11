#!/bin/sh

# Harden cron jobs
chmod 750 /etc/crontab
chmod 750 /etc/cron.hourly
chmod 750 /etc/cron.daily
chmod 750 /etc/cron.weekly
chmod 750 /etc/cron.monthly
chmod 750 /etc/cron.d
