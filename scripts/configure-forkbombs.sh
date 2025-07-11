#!/bin/sh

# Protect against fork bombs
grep -Fxq "* hard nproc 10000" /etc/security/limits.conf || echo "* hard nproc 10000" >> /etc/security/limits.conf
