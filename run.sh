#!/bin/sh

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

# Update system packages
apt update
apt upgrade -y

# Install essential security tools
apt install -y ufw fail2ban

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh/tcp
ufw enable
systemctl enable ufw

# Enable Fail2Ban
systemctl enable fail2ban
cp /etc/fail2ban/jail.{conf,local}
echo "[sshd]" >> /etc/fail2ban/jail.local
echo "enabled = true" >> /etc/fail2ban/jail.local

# Secure SSH configuration
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# Secure user accounts
passwd -l root # Lock the root account

# Configure automatic security updates
apt install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades

# Set strong password policy
apt install -y libpam-pwquality
sed -i 's/password requisite pam_pwquality.so retry=3/password requisite pam_pwquality.so retry=3 minlen=12 minclass=2 minclassrepeat=3 maxrepeat=3/' /etc/security/pwquality.conf
sed -i 's/password requisite pam_unix.so sha512/password requisite pam_unix.so sha512 minlen=8 remember=5/' /etc/pam.d/common-password

# Harden cron jobs
chmod 750 /etc/crontab
chmod 750 /etc/cron.hourly
chmod 750 /etc/cron.daily
chmod 750 /etc/cron.weekly
chmod 750 /etc/cron.monthly
chmod 750 /etc/cron.d

source scripts/tcp-harden.sh
