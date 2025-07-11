#!/bin/bash

if [ $(id -u) -ne 0 ]
    then echo Please run this script as root or using sudo!
    exit
fi

# Kernel Hardening Script for Ubuntu Systems

set -euo pipefail

echo "Starting kernel hardening..."

SYSCTL_FILE="/etc/sysctl.d/99-kernel-hardening.conf"

# Remove previous config
if [ -f "$SYSCTL_FILE" ]; then
    echo "Removing existing $SYSCTL_FILE..."
    rm -f "$SYSCTL_FILE"
fi

# Define kernel hardening parameters
declare -A kernel_hardening_params=(
    # Restrict core dumps
    ["fs.suid_dumpable"]=0

    # Randomize memory space layout
    ["kernel.randomize_va_space"]=2
)

# Write sysctl configuration
echo "# Kernel hardening configuration (auto-generated)" > "$SYSCTL_FILE"
for param in "${!kernel_hardening_params[@]}"; do
    value="${kernel_hardening_params[$param]}"
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

echo "Kernel hardening completed successfully!"
