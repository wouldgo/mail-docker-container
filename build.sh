#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
else

  apt-get install -y mysql-client

  MAILUSER_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
  MYSQL_IP=$(docker inspect $(docker ps | grep wouldgo/mysql | awk '{print $1}') | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["NetworkSettings"]["IPAddress"]')

  echo "Specify the admin user of mysql server..."
  read ADMIN

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-virtual-mailbox-domains.cf
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-virtual-mailbox-domains.cf

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-virtual-mailbox-maps.cf
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-virtual-mailbox-maps.cf

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-virtual-alias-maps.cf
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-virtual-alias-maps.cf

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/mysql-email2email.cf
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/mysql-email2email.cf

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/dovecot-sql.conf.ext
  sed -i -re"s/%MYSQL_IP%/$MYSQL_IP/g" confs/dovecot-sql.conf.ext

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" confs/create_mysql_db.sql
  mysql -u $(echo $ADMIN) -p -h $MYSQL_IP < confs/create_mysql_db.sql

  # Fake populate
  mysql -u $(echo $ADMIN) -p -h $MYSQL_IP < fake_populate.sql

  docker build --tag wouldgo/mail .
fi
