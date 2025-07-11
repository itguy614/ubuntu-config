#!/bin/bash

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

. "scripts/remove-snaps.sh"

# Update system packages
apt update
apt upgrade -y

# Define an array of scripts to run
SCRIPTS=(
    "scripts/configuer-auditd.sh"
    "scripts/configure-autoupdate.sh"
    "scripts/configure-chrony.sh"
    "scripts/configure-cron.sh"
    "scripts/configure-fail2ban.sh"
    "scripts/configure-firewall.sh"
    "scripts/configure-forkbombs.sh"
    "scripts/configure-issue.sh"
    "scripts/configure-logrotate.sh"
    "scripts/configure-motd.sh"
    "scripts/configure-passwordpolicy.sh"
    "scripts/configure-sshd.sh"
    "scripts/file-tune.sh"
    "scripts/kernel-harden.sh"
    "scripts/tcp-harden.sh"
    "scripts/tcp-tune.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        . "$script"
    else
        echo "Warning: $script not found. Skipping."
    fi
done

# Remove unnecessary packages
apt autoremove --purge -y
