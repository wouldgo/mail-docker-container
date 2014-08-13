#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
else

  apt-get install -y mysql-client

  MAILUSER_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
  MYSQL_IP=$(docker inspect $(docker ps | grep mysqld | awk '{print $1}') | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["NetworkSettings"]["IPAddress"]')

  echo "Mysql ip is $MYSQL_IP" && \

  DEFAULT_HOSTNAME=$(hostname) && \
  read -p "Specify the machine hostname [$DEFAULT_HOSTNAME]: " HOSTNAME && \
  HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME} && \

  echo "Specify the admin user for mysql server..." && \
  read ADMIN && \

  echo "Specify the admin password for mysql server..." && \
  read -s PASSWORD && \

  useradd \
  --shell /bin/bash \
  --home-dir /home/mail-user \
  --no-create-home \
  --uid 5000 \
  --comment "mail docker container user" \
  vmail || { echo "User for mailer alredy present"; } && \

  mkdir mail && \
  mkdir logs

  sed -i -re"s/%HOSTNAME%/$HOSTNAME/g" Dockerfile && \

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/create_mysql_db.sql && \

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/connect-line-dovecot-sql.conf.ext && \
  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-virtual-mailbox-domains.cf && \
  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-virtual-mailbox-maps.cf && \
  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-virtual-alias-maps.cf && \

  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/connect-line-dovecot-sql.conf.ext && \
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-virtual-mailbox-domains.cf && \
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-virtual-mailbox-maps.cf && \
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-virtual-alias-maps.cf && \
  mysql -u $(echo $ADMIN) -p$(echo $PASSWORD) -h $MYSQL_IP < confs/create_mysql_db.sql && \

  chown -Rfv vmail:vmail logs/ mail/ && \

  docker build --tag wouldgo/mail .
fi
