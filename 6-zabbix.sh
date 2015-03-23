#!/bin/bash
#
# 6. zabbix
#
HOSTNAME=${HOSTNAME:-`hostname`}
ZABBIX=${ZABBIX:-"127.0.0.1"}

# 6.1. zabbix
yum -y install zabbix-agent
find / -group zabbix | xargs chgrp 116
find / -user zabbix | xargs chown 116
groupmod -g 116 zabbix
usermod -u 116 zabbix

# 6.2. zabbix-config
sed -e "s/=127.0.0.1$/=${ZABBIX}/g" -e "s/^Hostname=.*$/Hostname=${HOSTNAME}/g" -i.dist /etc/zabbix/zabbix_agentd.conf

# 6.X. zabbix-service
service zabbix-agent start
chkconfig zabbix-agent on
