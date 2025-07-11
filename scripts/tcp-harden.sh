#!/bin/bash

# TCP Hardening Script for Ubuntu Systems
# Must be run with root privileges.

set -euo pipefail

echo "Starting TCP hardening..."

SYSCTL_FILE="/etc/sysctl.d/99-tcp-hardening.conf"

# Delete old drop-in file if it exists
if [ -f "$SYSCTL_FILE" ]; then
    echo "Removing existing $SYSCTL_FILE..."
    rm -f "$SYSCTL_FILE"
fi

# Define kernel parameters for TCP hardening
declare -A tcp_hardening_params=(
    # IPv4 redirect & source route protection
    ["net.ipv4.conf.all.accept_redirects"]=0
    ["net.ipv4.conf.default.accept_redirects"]=0
    ["net.ipv4.conf.all.accept_source_route"]=0
    ["net.ipv4.conf.default.accept_source_route"]=0

    # Martian logging
    ["net.ipv4.conf.all.log_martians"]=1
    ["net.ipv4.conf.default.log_martians"]=1

    # Reverse path filtering (strict mode)
    ["net.ipv4.conf.all.rp_filter"]=2
    ["net.ipv4.conf.default.rp_filter"]=2

    # Disable sending ICMP redirects
    ["net.ipv4.conf.all.send_redirects"]=0
    ["net.ipv4.conf.default.send_redirects"]=0

    # ICMP protections
    ["net.ipv4.icmp_echo_ignore_broadcasts"]=1
    ["net.ipv4.icmp_ignore_bogus_error_responses"]=1

    # Disable IP forwarding
    ["net.ipv4.ip_forward"]=0

    # Port range
    ["net.ipv4.ip_local_port_range"]="1024 65535"

    # TCP tuning
    ["net.ipv4.tcp_fin_timeout"]=15
    ["net.ipv4.tcp_keepalive_intvl"]=15
    ["net.ipv4.tcp_keepalive_probes"]=5
    ["net.ipv4.tcp_keepalive_time"]=300
    ["net.ipv4.tcp_max_syn_backlog"]=2048
    ["net.ipv4.tcp_rfc1337"]=1
    ["net.ipv4.tcp_syn_retries"]=2
    ["net.ipv4.tcp_synack_retries"]=2
    ["net.ipv4.tcp_syncookies"]=1
    ["net.ipv4.tcp_timestamps"]=0
    ["net.ipv4.tcp_tw_recycle"]=0
    ["net.ipv4.tcp_tw_reuse"]=1
    ["net.ipv4.tcp_window_scaling"]=0

    # Disable IPv6 if not used
    ["net.ipv6.conf.all.disable_ipv6"]=1
    ["net.ipv6.conf.default.disable_ipv6"]=1
)

# Create a fresh drop-in sysctl file
echo "# TCP hardening configuration (auto-generated)" > "$SYSCTL_FILE"

# Apply parameters and write to file
for param in "${!tcp_hardening_params[@]}"; do
    value="${tcp_hardening_params[$param]}"
    echo "Applying $param = $value"
    sysctl -w "$param=$value"
    echo "$param = $value" >> "$SYSCTL_FILE"
done

# Reload sysctl settings from all config files
echo "Reloading sysctl settings..."
sysctl --system

echo "TCP hardening completed successfully!"
