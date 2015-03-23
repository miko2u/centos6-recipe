#
# 7. docker 1.4+
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
sed -i.dist 's/^other_args=.*$/other_args="-H 0.0.0.0:2375 -H unix:///var/run/docker.sock"/g' /etc/sysconfig/docker
service docker start
chkconfig docker on
