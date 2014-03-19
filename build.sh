#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
else

  apt-get install -y pwgen mysql-client

  MAILUSER_PSW=$(pwgen -s 30 1)
  TAG="wouldgo/mysql"
  CONTAINER_ID=$(docker ps | grep $TAG | awk '{print $1}')
  IP=$(docker inspect $CONTAINER_ID | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["NetworkSettings"]["IPAddress"]')

  echo "Specify the admin user of mysql server..."
  read ADMIN

  sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" create_mysql_db.sql
  mysql -u $(echo $ADMIN) -p -h $IP < create_mysql_db.sql

  # Fake populate
  mysql -u $(echo $ADMIN) -p -h $IP < fake_populate.sql


  docker build -t wouldgo/mail .
  echo "

  This is the mailuser password: $MAILUSER_PSW (SAVE IT!)"
fi
