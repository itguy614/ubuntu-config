#!/bin/bash

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

# TCP Tuning Script for Ubuntu Systems

set -euo pipefail

echo "Starting TCP tuning..."

SYSCTL_FILE="/etc/sysctl.d/99-tcp-tuning.conf"

# Remove existing config to ensure it is rewritten
if [ -f "$SYSCTL_FILE" ]; then
    echo "Removing existing $SYSCTL_FILE..."
    rm -f "$SYSCTL_FILE"
fi

# Define kernel parameters for TCP tuning and performance
declare -A tcp_tuning_params=(
    # Core socket buffers and performance
    ["net.core.rmem_default"]=31457280
    ["net.core.rmem_max"]=12582912
    ["net.core.wmem_default"]=31457280
    ["net.core.wmem_max"]=12582912
    ["net.core.somaxconn"]=65536
    ["net.core.netdev_max_backlog"]=65536
    ["net.core.optmem_max"]=25165824

    # Memory and port range
    ["net.ipv4.tcp_mem"]="65536 131072 262144"
    ["net.ipv4.udp_mem"]="65536 131072 262144"
    ["net.ipv4.tcp_rmem"]="8192 87380 16777216"
    ["net.ipv4.tcp_wmem"]="8192 65536 16777216"
    ["net.ipv4.udp_rmem_min"]=16384
    ["net.ipv4.udp_wmem_min"]=16384
    ["net.ipv4.tcp_max_tw_buckets"]=1440000
    ["net.ipv4.tcp_tw_reuse"]=1

    # TCP backlog, timeouts, latency
    ["net.ipv4.tcp_max_syn_backlog"]=8192
    ["net.ipv4.tcp_fin_timeout"]=10
    ["net.ipv4.tcp_low_latency"]=1

    # Enable BBR (if supported)
    ["net.core.default_qdisc"]="fq"
    ["net.ipv4.tcp_congestion_control"]="bbr"

    # Security enhancements
    ["net.ipv4.conf.all.shared_media"]=0
    ["net.ipv4.conf.all.arp_filter"]=1

    # Optional: connection tracking (useful for NAT/firewall servers)
    ["net.netfilter.nf_conntrack_max"]=262144

    # Optional: increase system-wide file descriptors (not sysctl.conf but added here for awareness)
    ["fs.file-max"]=2097152
)

# Create the new sysctl drop-in file
echo "# TCP tuning configuration (auto-generated)" > "$SYSCTL_FILE"

# Apply each parameter and persist it
for param in "${!tcp_tuning_params[@]}"; do
    value="${tcp_tuning_params[$param]}"
    echo "Applying $param = $value"
    sysctl -w "$param=$value"
    echo "$param = $value" >> "$SYSCTL_FILE"
done

# Set permissions on the sysctl file
chmod 644 "$SYSCTL_FILE"
chown root:root "$SYSCTL_FILE"

# Reload all sysctl settings
echo "Reloading sysctl settings..."
sysctl --system

echo "TCP tuning completed successfully!"
