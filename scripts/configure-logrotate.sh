#!/bin/bash

if [ $(id -u) -ne 0 ]
    then echo Please run this script as root or using sudo!
    exit
fi

# Log Rotation Configuration Script for Ubuntu Systems

set -euo pipefail

echo "Configuring log rotation to prevent disk exhaustion..."

LOGROTATE_CONF="/etc/logrotate.d/custom-logs"

# Create a custom logrotate configuration
cat > "$LOGROTATE_CONF" <<EOF
# Custom log rotation configuration
/var/log/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root adm
    sharedscripts
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate || true
    endscript
}
EOF

# Set permissions on the logrotate configuration file
chmod 644 "$LOGROTATE_CONF"
chown root:root "$LOGROTATE_CONF"

echo "Log rotation configuration completed successfully!"
