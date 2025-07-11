#!/bin/bash

if [ $(id -u) -ne 0 ]
    then echo "Please run this script as root or using sudo!"
    exit
fi

# MOTD Configuration Script for Ubuntu Systems

set -euo pipefail

echo "Configuring MOTD to display dynamic system information and warnings..."

# Step 1: Remove or disable existing /etc/update-motd.d/ scripts
echo "Disabling existing MOTD scripts..."
MOTD_DIR="/etc/update-motd.d"
BACKUP_DIR="/etc/update-motd.d/backup"

# Create a backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Move existing scripts to the backup directory, excluding the backup directory itself
find "$MOTD_DIR" -maxdepth 1 -type f -exec mv {} "$BACKUP_DIR/" \;

# Step 2: Create a custom dynamic MOTD script
MOTD_SCRIPT="$MOTD_DIR/99-custom-motd"

cat > "$MOTD_SCRIPT" <<'EOF'
#!/bin/bash

# Collect system information dynamically
HOSTNAME=$(hostname)
UPTIME=$(uptime -p)
LOAD=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
MEMORY=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
DISK=$(df -h / | awk '/^\/dev/ {print $1 ": " $3 "/" $2 " (" $5 " used)"}')
IP_ADDRESSES=$(ip -4 -o addr show | awk '{print $2 ": " $4}' | sed 's/\/[0-9]*//')
OS_VERSION=$(lsb_release -d | awk -F"\t" '{print $2}')
UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo "0")
RELEASE_UPGRADE=$(do-release-upgrade -c 2>/dev/null | grep -q "New release" && echo "Yes" || echo "No")

# Display the MOTD
cat <<EOM

$HOSTNAME ($OS_VERSION)
--------------------------------------------------------------------------------
Uptime: $UPTIME
Memory Usage: $MEMORY

$DISK

$IP_ADDRESSES

Available Updates: $UPDATES
Release Upgrade Available: $RELEASE_UPGRADE

********************************************************************************
                        Unauthorized access is prohibited.
                     All activities are monitored and logged.
********************************************************************************

EOM
EOF

# Step 3: Set permissions on the custom MOTD script
chmod 755 "$MOTD_SCRIPT"
chown root:root "$MOTD_SCRIPT"

echo "Dynamic MOTD configuration completed successfully!"
