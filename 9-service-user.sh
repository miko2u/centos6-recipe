#!/bin/bash

# mysql
# note: container user "mysql" shell is /bin/bash. but, host machine recommended /sbin/nologin for security
groupadd -g 27 -o -r mysql
useradd -M -N -g mysql -o -r -d /var/lib/mysql -s /sbin/nologin -c "MySQL Server" -u 27 mysql
install -p -d -m 0755 -o 27 -g 27 /var/lib/mysql
install -p -d -m 0750 -o 27 -g 27 /var/log/mysql

# nginx
# note: container user "nginx" is 498
groupadd -g 498 -r nginx
useradd -g 498 -r -d /var/lib/nginx -s /sbin/nologin -c "Nginx web server" -u 498 nginx
install -p -d -m 0755 -o 498 -g 498 /etc/nginx/conf.d
install -p -d -m 0755 -o 498 -g 498 /etc/nginx/default.d
install -p -d -m 0700 -o 498 -g 498 /var/lib/nginx
install -p -d -m 0700 -o 498 -g 498 /var/lib/nginx/tmp
install -p -d -m 0700 -o 498 -g 498 /var/log/nginx
install -p -d -m 0755 -o 0 -g 0 /var/www

# redis
# note: container user "redis" is 496
groupadd -g 496 -o -r redis
useradd -M -N -g redis -o -r -d /var/lib/redis -s /sbin/nologin -c "Redis Server" -u 496 redis
install -p -d -m 0755 -o 496 -g 0 /var/lib/redis
install -p -d -m 0755 -o 496 -g 0 /var/log/redis

# rabbitmq
# note: container user "rabbitmq" shell is /bin/bash. but, host machine recommended /sbin/nologin for security
groupadd -g 495 -o -r rabbitmq
useradd -M -N -g rabbitmq -o -r -d /var/lib/rabbitmq -s /sbin/nologin -c "RabbitMQ messaging server" -u 495 rabbitmq
install -p -d -m 0755 -o 0 -g 0 /etc/rabbitmq
install -p -d -m 0755 -o 495 -g 0 /var/lib/rabbitmq
install -p -d -m 0755 -o 495 -g 0 /var/log/rabbitmq
