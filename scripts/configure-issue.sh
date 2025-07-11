#!/bin/bash

if [ $(id -u) -ne 0 ]
    then echo "Please run this script as root or using sudo!"
    exit
fi

# ISSUE and ISSUE.NET Configuration Script for Ubuntu Systems

set -euo pipefail

echo "Configuring /etc/issue and /etc/issue.net..."

ISSUE_FILE="/etc/issue"
ISSUE_NET_FILE="/etc/issue.net"

# Collect system information
HOSTNAME=$(hostname)
OS=$(lsb_release -d | awk -F"\t" '{print $2}')

# Create a custom /etc/issue
cat > "$ISSUE_FILE" <<EOF
$HOSTNAME ($OS)
Unauthorized access is prohibited.
--------------------------------------------------------------------------------
EOF

# Remove existing /etc/issue.net if it exists and create a symlink
if [ -f "$ISSUE_NET_FILE" ] || [ -L "$ISSUE_NET_FILE" ]; then
    rm -f "$ISSUE_NET_FILE"
fi
ln -s "$ISSUE_FILE" "$ISSUE_NET_FILE"

# Set permissions on the /etc/issue file
chmod 644 "$ISSUE_FILE"
chown root:root "$ISSUE_FILE"

echo "/etc/issue configured and /etc/issue.net symlinked to /etc/issue successfully!"
