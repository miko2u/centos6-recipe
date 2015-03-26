#!/bin/bash
#
# A. SSHD
#
SSH_PORT=${SSH_PORT:-22}

cp -pri /etc/ssh/sshd_config /etc/ssh/sshd_config.dist
sed -i "s/^#Port 22/Port ${SSH_PORT}/" /etc/ssh/sshd_config
sed -i "s/^PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/^UsePAM yes/UsePAM no/" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin yes/PermitRootLogin without-password/" /etc/ssh/sshd_config
sed -i "s/^X11Forwarding yes//g" /etc/ssh/sshd_config
service sshd restart
