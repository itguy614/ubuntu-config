#!/bin/bash

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

# TCP Hardening Script for Ubuntu Systems

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

    # ICMP rate limiting
    ["net.ipv4.icmp_ratelimit"]=100
    ["net.ipv4.icmp_ratemask"]="0x1f"

    # Shared media
    ["net.ipv4.conf.all.shared_media"]=0
    ["net.ipv4.conf.all.arp_filter"]=1


    # Disable IPv6 if not used
    ["net.ipv6.conf.all.disable_ipv6"]=1
    ["net.ipv6.conf.default.disable_ipv6"]=1
    ["net.ipv6.conf.lo.disable_ipv6"]=1
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
