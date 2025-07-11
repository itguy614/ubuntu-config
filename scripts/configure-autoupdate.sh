#!/bin/sh

# Configure automatic security updates
apt install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades
