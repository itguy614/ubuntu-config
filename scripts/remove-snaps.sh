#!/bin/sh

if [ $(id -u) -ne 0 ]; then
    echo "Please run this script as root or using sudo!"
    exit 1
fi

# Remove all installed snaps and snapd
snap list | awk 'NR>1 {print $1}' | xargs -I{} snap remove --purge {}
apt purge -y snapd

# Remove snap-related directories
rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd

# Prevent snapd from being installed again
echo "Package: snapd" > /etc/apt/preferences.d/no-snapd
echo "Pin: release *" >> /etc/apt/preferences.d/no-snapd
echo "Pin-Priority: -1" >> /etc/apt/preferences.d/no-snapd

# Update package lists
apt update

echo "Snaps have been removed and snapd is disabled."
