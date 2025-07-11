#!/bin/sh

if [ $(id -u) -ne 0 ]
    then echo Please run this script as root or using sudo!
    exit
fi

apt remove --purge -y ufw

# Copy this script to /usr/local/sbin/custom-firewall.sh for systemd service
cp custom-firewall.sh /usr/local/sbin/custom-firewall.sh
chmod +x /usr/local/sbin/custom-firewall.sh

# Install systemd service unit
SERVICE_PATH="/etc/systemd/system/custom-firewall.service"
cat <<EOF > "$SERVICE_PATH"
[Unit]
Description=Custom Firewall Rules
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/custom-firewall.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable custom-firewall
systemctl restart custom-firewall
