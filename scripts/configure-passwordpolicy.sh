#!/bin/sh

if [ $(id -u) -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

# Secure user accounts
passwd -l root # Lock the root account

# Set strong password policy
apt install -y libpam-pwquality
sed -i 's/password requisite pam_pwquality.so retry=3/password requisite pam_pwquality.so retry=3 minlen=12 minclass=2 minclassrepeat=3 maxrepeat=3/' /etc/security/pwquality.conf
sed -i 's/password requisite pam_unix.so sha512/password requisite pam_unix.so sha512 minlen=8 remember=5/' /etc/pam.d/common-password

# Set password aging and login security
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs

# Ensure only users in 'sudo' group can escalate
sed -i 's/^%sudo.*/%sudo   ALL=(ALL:ALL) ALL/' /etc/sudoers
chmod 440 /etc/sudoers
chown root:root /etc/sudoers
