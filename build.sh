#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
else

  apt-get install -y mysql-client

  MAILUSER_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
  MYSQL_IP=$(docker inspect $(docker ps | grep wouldgo/mysql | awk '{print $1}') | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["NetworkSettings"]["IPAddress"]')

  echo "Specify the admin user for mysql server..."
  read ADMIN

  echo "Specify the admin password for mysql server..."
  read -s PASSWORD

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-virtual-mailbox-domains.cf && \
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-virtual-mailbox-domains.cf && \

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-virtual-mailbox-maps.cf && \
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-virtual-mailbox-maps.cf && \

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-virtual-alias-maps.cf && \
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-virtual-alias-maps.cf && \

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-email2email.cf && \
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-email2email.cf && \

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/dovecot-sql.conf.ext && \
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/dovecot-sql.conf.ext && \

  mysqldump -u $(echo $ADMIN) -p$(echo $PASSWORD) -h $MYSQL_IP --no-create-info mailserver virtual_domains virtual_users virtual_aliases > confs/previous_dump.sql && \

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/create_mysql_db.sql && \
  mysql -u $(echo $ADMIN) -p$(echo $PASSWORD) -h $MYSQL_IP < confs/create_mysql_db.sql && \
  mysql -u $(echo $ADMIN) -p$(echo $PASSWORD) -h $MYSQL_IP --database=mailserver < confs/previous_dump.sql && \

  docker build --tag wouldgo/mail . && \

  echo "confs/mysql-virtual-mailbox-domains.cf" >> .gitignore && \
  echo "confs/mysql-virtual-mailbox-maps.cf" >> .gitignore && \
  echo "confs/mysql-virtual-alias-maps.cf" >> .gitignore && \
  echo "confs/mysql-email2email.cf" >> .gitignore && \
  echo "confs/dovecot-sql.conf.ext" >> .gitignore
fi
