#!/bin/bash
#
# 3. secure
#
SSH_PORT=${SSH_PORT:-22}

# 3.1. logging
cat << __EOT__ > /etc/rsyslog.d/iptables.conf
:msg, contains, "[IPTABLES]"	-/var/log/iptables
:msg, contains, "[IP4FLOOD]"	-/var/log/iptables
:msg, contains, "[UDPFLOOD]"	-/var/log/iptables
:msg, contains, "[SYNFLOOD]"	-/var/log/iptables
:msg, contains, "[SSHFORCE]"	-/var/log/iptables
__EOT__

# 3.2. logrotate logging
cat << __EOT__ > /etc/logrotate.d/iptables
/var/log/iptables {
    daily
    rotate 14
    sharedscripts
    postrotate
        /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}
__EOT__

# 3.3. ip6tables
cat << __EOT__ > /etc/sysconfig/ip6tables
# Firewall configuration written by system-config-firewall
# Manual customization of this file is not recommended.
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:C_SSH - [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p IPV6-icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j C_SSH
-A INPUT -m state --state NEW -m tcp -p tcp --dport ${SSH_PORT} -j C_SSH
-A INPUT -j REJECT --reject-with icmp6-adm-prohibited
-A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
-A C_SSH -m hashlimit --hashlimit-upto 1/min --hashlimit-burst 7 --hashlimit-mode srcip --hashlimit-name ssh --hashlimit-htable-expire 180000 -j ACCEPT
-A C_SSH -m limit --limit 1/sec --limit-burst 1000 -j LOG --log-prefix "[SSHFORCE] " --log-level 7
-A C_SSH -j DROP
COMMIT
__EOT__
chmod 600 /etc/sysconfig/ip6tables

# 3.4. iptables - basic
cat << __EOT__ > /etc/sysconfig/iptables
# Firewall configuration written by system-config-firewall
# Manual customization of this file is not recommended.
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:C_ICMP - [0:0]
:C_UDP - [0:0]
:C_SSH - [0:0]
:C_HTTP - [0:0]
:C_HTTPS - [0:0]
:F_ATTACK - [0:0]
:MONITOR - [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j C_ICMP
-A INPUT -i lo -j ACCEPT
-A INPUT -i eth1 -j ACCEPT
-A INPUT -i eth2 -j ACCEPT
-A INPUT -s 172.17.0.0/16 -i docker0 -j ACCEPT
-A INPUT -j F_ATTACK
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j C_SSH
-A INPUT -p tcp -m state --state NEW -m tcp --dport ${SSH_PORT} -j C_SSH
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j C_HTTP
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j C_HTTPS
-A INPUT -p tcp -m state --state NEW -m tcp --dport 5666 -j MONITOR
-A INPUT -p tcp -m state --state NEW -m tcp --dport 10050 -j MONITOR
-A INPUT -p tcp -m multiport --dports 135,137,138,139,445 -j DROP
-A INPUT -p udp -m multiport --dports 135,137,138,139,445 -j DROP
-A INPUT -m pkttype --pkt-type broadcast -j DROP
-A INPUT -m pkttype --pkt-type multicast -j DROP
-A INPUT -m limit --limit 1/sec --limit-burst 1000 -j LOG --log-prefix "[IPTABLES] " --log-level 7
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
-A C_HTTP -m hashlimit --hashlimit-upto 10/min --hashlimit-burst 60 --hashlimit-mode srcip --hashlimit-name http --hashlimit-htable-expire 60000 -j ACCEPT
-A C_HTTP -m limit --limit 1/sec --limit-burst 1000 -j LOG --log-prefix "[SYNFLOOD] " --log-level 7
-A C_HTTP -j DROP
-A C_HTTPS -m hashlimit --hashlimit-upto 30/min --hashlimit-burst 60 --hashlimit-mode srcip --hashlimit-name https --hashlimit-htable-expire 60000 -j ACCEPT
-A C_HTTPS -m limit --limit 1/sec --limit-burst 1000 -j LOG --log-prefix "[SYNFLOOD] " --log-level 7
-A C_HTTPS -j DROP
-A C_ICMP -m hashlimit --hashlimit-upto 30/min --hashlimit-burst 60 --hashlimit-mode srcip --hashlimit-name icmp --hashlimit-htable-expire 60000 -j ACCEPT
-A C_ICMP -m limit --limit 1/sec --limit-burst 1000 -j LOG --log-prefix "[IP4FLOOD] " --log-level 7
-A C_ICMP -j DROP
-A C_UDP -m hashlimit --hashlimit-upto 30/min --hashlimit-burst 60 --hashlimit-mode srcip --hashlimit-name udp --hashlimit-htable-expire 60000 -j ACCEPT
-A C_UDP -m limit --limit 1/sec --limit-burst 1000 -j LOG --log-prefix "[UDPFLOOD] " --log-level 7
-A C_UDP -j DROP
-A C_SSH -m hashlimit --hashlimit-upto 1/min --hashlimit-burst 7 --hashlimit-mode srcip --hashlimit-name ssh --hashlimit-htable-expire 180000 -j ACCEPT
-A C_SSH -m limit --limit 1/sec --limit-burst 1000 -j LOG --log-prefix "[SSHFORCE] " --log-level 7
-A C_SSH -j DROP
-A MONITOR -s ${NAGIOS} -j ACCEPT
-A MONITOR -s ${ZABBIX} -j ACCEPT
-A MONITOR -j REJECT --reject-with icmp-host-prohibited
COMMIT
__EOT__
chmod 600 /etc/sysconfig/iptables

# 3.X. restart
service ip6tables restart
service iptables restart
