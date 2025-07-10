#!/bin/bash

# File System & I/O Tuning Script for Light-Duty Ubuntu Servers (VPN/Web, No Swap)
# Must be run with root privileges.

set -euo pipefail

echo "Starting file system and I/O tuning for network-oriented lightweight server..."

SYSCTL_FILE="/etc/sysctl.d/99-fs-tuning.conf"

# Remove previous config
if [ -f "$SYSCTL_FILE" ]; then
    echo "Removing existing $SYSCTL_FILE..."
    rm -f "$SYSCTL_FILE"
fi

# Define sysctl parameters
declare -A fs_tuning_params=(
    # Swap minimization
    ["vm.swappiness"]=1                 # Prevent swapping except under extreme conditions
    ["vm.overcommit_memory"]=1          # Allow memory overcommit (safe with lots of RAM)
    ["vm.overcommit_ratio"]=100         # Effectively disables limit

    # Filesystem caching
    ["vm.vfs_cache_pressure"]=50        # Balanced caching of inode/dentry data

    # Dirty memory writeback: prevent background I/O during bursts of VPN/web traffic
    ["vm.dirty_background_ratio"]=5     # Start writeback only after 5% of RAM is dirty
    ["vm.dirty_ratio"]=15               # Force flush when 15% of RAM is dirty
    ["vm.dirty_expire_centisecs"]=3000  # Dirty pages considered old after 30 sec
    ["vm.dirty_writeback_centisecs"]=1000 # Background writeback every 10 sec
)

# Write sysctl configuration
echo "# Tuning for lightweight network server (auto-generated)" > "$SYSCTL_FILE"
for param in "${!fs_tuning_params[@]}"; do
    value="${fs_tuning_params[$param]}"
    echo "Applying $param = $value"
    sysctl -w "$param=$value"
    echo "$param = $value" >> "$SYSCTL_FILE"
done

# Enforce sysctl file permissions
chmod 644 "$SYSCTL_FILE"
chown root:root "$SYSCTL_FILE"

# Reload sysctl settings
echo "Reloading sysctl settings..."
sysctl --system

# Set user-level file descriptor limits
LIMITS_FILE="/etc/security/limits.d/99-fd-limits.conf"
echo "Setting open file limits in $LIMITS_FILE..."
cat > "$LIMITS_FILE" <<EOF
* soft nofile 262144
* hard nofile 262144
EOF

# Disable swap at runtime and in fstab
echo "Disabling swap..."
swapoff -a
echo "Commenting out swap entries in /etc/fstab..."
sed -i.bak '/\sswap\s/s/^/#/' /etc/fstab

echo "File system and I/O tuning for light-duty network server completed successfully!"
