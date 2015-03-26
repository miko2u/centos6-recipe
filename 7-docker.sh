#!/bin/bash
#
# 7. docker
#

# 7.1. docker
yum -y install docker-io docker-io-vim
find / -group cgred | xargs chgrp 150
groupmod -g 150 cgred
find / -group docker | xargs chgrp 151
groupmod -g 151 docker

# 7.2. docker-compose
curl -L https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/fig

# 7.3. docker-config
sed -e 's%^other_args=.*$%other_args="-H 0.0.0.0:2375 -H unix:///var/run/docker.sock"%g' \
	-i.dist /etc/sysconfig/docker
service docker start
chkconfig docker on

# 7.4. docker-utils
cat << '__EOT__' > /etc/sysconfig/docker-cron
# CRON_DAILY=true
# CRON_WEEKLY=true
# CRON_MONTHLY=true
__EOT__

cat << '__EOT__' > /etc/cron.daily/docker-cron.daily 
#!/bin/sh

CRON_DAILY=true
[ -f /etc/sysconfig/docker-cron ] && source /etc/sysconfig/docker-cron

if [ $CRON_DAILY == true ]; then
    for id in $(docker ps -q); do
        exec $(docker exec $id nice run-parts /etc/cron.daily > /dev/null 2&>1)
    done
fi
exit 0
__EOT__

sed -e 's/DAILY/WEEKLY/g' -e 's/daily/weekly/g' /etc/cron.daily/docker-cron.daily > /etc/cron.weekly/docker-cron.weekly
sed -e 's/DAILY/MONTHLY/g' -e 's/daily/monthly/g' /etc/cron.daily/docker-cron.daily > /etc/cron.monthly/docker-cron.monthly
chmod 644 /etc/sysconfig/docker-cron
chmod 755 /etc/cron.daily/docker-cron.daily /etc/cron.weekly/docker-cron.weekly /etc/cron.monthly/docker-cron.monthly

# vim:ts=4
