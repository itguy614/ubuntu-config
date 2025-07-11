#!/bin/bash

# Must be run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root or with sudo."
    exit 1
fi

echo "[*] Preparing Ubuntu system for template conversion..."

### Set timezone to UTC
echo "[*] Setting timezone to UTC..."
timedatectl set-timezone UTC

### Remove cloud-init
echo "[*] Removing cloud-init..."
apt purge -y cloud-init
rm -rf /etc/cloud/ /var/lib/cloud/

### Clear machine ID and D-Bus ID
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

### Remove SSH host keys (regenerate on boot)
echo "[*] Removing SSH host keys..."
rm -f /etc/ssh/ssh_host_*
cat << 'EOF' > /usr/local/bin/regen-ssh-keys.sh
#!/bin/bash
/usr/bin/ssh-keygen -A
EOF
chmod +x /usr/local/bin/regen-ssh-keys.sh
cat << EOF > /etc/systemd/system/regen-ssh-keys.service
[Unit]
Description=Regenerate SSH host keys
Before=ssh.service
ConditionPathExists=!/etc/ssh/ssh_host_rsa_key

[Service]
Type=oneshot
ExecStart=/usr/local/bin/regen-ssh-keys.sh

[Install]
WantedBy=multi-user.target
EOF
systemctl enable regen-ssh-keys.service

### Prompt for hostname on first login
echo "[*] Creating hostname prompt on first login..."
cat << 'EOF' > /etc/profile.d/set-hostname.sh
#!/bin/bash
if id -nG | grep -qw sudo && [ ! -f /etc/hostname_initialized ]; then
  read -p "Enter hostname for this system: " NEW_HOSTNAME
  echo "$NEW_HOSTNAME" | sudo tee /etc/hostname > /dev/null
  sudo hostnamectl set-hostname "$NEW_HOSTNAME"
  sudo touch /etc/hostname_initialized
fi
EOF
chmod +x /etc/profile.d/set-hostname.sh
rm -f /etc/hostname_initialized

### Prompt for hypervisor and install tools on first login
echo "[*] Creating hypervisor integration prompt on first login..."
cat << 'EOF' > /etc/profile.d/install-hypervisor-tools.sh
#!/bin/bash
if id -nG | grep -qw sudo && [ ! -f /etc/hypervisor_initialized ]; then
  read -p "Enter hypervisor type (kvm/vmware/hyperv/none): " HYPERVISOR
  case "$HYPERVISOR" in
    kvm)
      sudo apt update
      sudo apt install -y qemu-guest-agent spice-vdagent
      sudo systemctl enable qemu-guest-agent
      ;;
    vmware)
      sudo apt update
      sudo apt install -y open-vm-tools
      sudo systemctl enable open-vm-tools
      ;;
    hyperv)
      sudo apt update
      sudo apt install -y linux-cloud-tools-$(uname -r) linux-tools-$(uname -r)
      ;;
    none)
      echo "Skipping hypervisor integration tools."
      ;;
    *)
      echo "Unknown option. No tools installed."
      ;;
  esac
  sudo touch /etc/hypervisor_initialized
fi
EOF
rm -f /etc/hypervisor_initialized
chmod +x /etc/profile.d/install-hypervisor-tools.sh

### Auto-expand root partition on first boot
echo "[*] Enabling root partition expansion..."
apt install -y cloud-guest-utils gdisk
cat << 'EOF' > /usr/local/bin/resize-rootfs.sh
#!/bin/bash
/usr/bin/growpart /dev/sda 1
/sbin/resize2fs /dev/sda1
EOF
chmod +x /usr/local/bin/resize-rootfs.sh
cat << EOF > /etc/systemd/system/resize-rootfs.service
[Unit]
Description=Resize root filesystem
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/resize-rootfs.sh

[Install]
WantedBy=multi-user.target
EOF
systemctl enable resize-rootfs.service

### Install generic kernel
echo "[*] Installing generic kernel..."
apt install -y linux-generic
apt autoremove --purge -y

### Cleanup logs, identifiers, and sensitive files
echo "[*] Cleaning up logs, APT cache, and temporary files..."
apt clean
rm -rf /var/log/*
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/lib/dhcp/*
rm -f /root/.bash_history
rm -f /home/*/.bash_history
rm -f /etc/udev/rules.d/70-persistent-net.rules

### Limit systemd journal size
echo "[*] Limiting journal size..."
mkdir -p /etc/systemd/journald.conf.d
cat <<EOF > /etc/systemd/journald.conf.d/limit-size.conf
[Journal]
SystemMaxUse=200M
RuntimeMaxUse=100M
EOF

### Remove /etc/machine-info
echo "[*] Removing machine-info..."
rm -f /etc/machine-info

### Remove APT history logs
echo "[*] Removing APT history..."
rm -f /var/log/apt/history.log /var/log/apt/term.log

echo "[✓] Template preparation complete. Shut down and convert this VM to a template."
