#!/bin/sh

# Install and configure auditd
apt install -y auditd audispd-plugins
systemctl enable auditd
systemctl start auditd

# Add audit rules only if they don't already exist
AUDIT_RULES_FILE="/etc/audit/rules.d/audit.rules"

add_audit_rule() {
    local rule="$1"
    grep -qxF '$rule' "$AUDIT_RULES_FILE" || echo "$rule" >> "$AUDIT_RULES_FILE"
}

add_audit_rule "-w /etc/ssh/sshd_config -p wa -k sshd_config"
add_audit_rule "-w /etc/passwd -p wa -k passwd"
add_audit_rule "-w /etc/shadow -p wa -k shadow"
add_audit_rule "-w /etc/sudoers -p wa -k sudoers"
add_audit_rule "-w /var/log/auth.log -p wa -k authlog"
add_audit_rule "-w /var/log/syslog -p wa -k syslog"

systemctl restart auditd
