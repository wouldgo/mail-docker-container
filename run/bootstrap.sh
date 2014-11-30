#!/bin/bash

MAIL_HOSTNAME = $MAIL_HOST
MAILUSER_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
DB_IP=$DB_PORT_3306_TCP_ADDR
SQL_USER=$USER
SQL_PASSWORD=$PSW

echo "Starting mail container for $MAIL_HOSTNAME using database at $DB_IP ..."

sed -i -re"s/^myhostname.*/myhostname = $MAIL_HOSTNAME/g" /etc/postfix/main.cf && \
echo "postmaster_address=postmaster at $MAIL_HOSTNAME" >> /etc/dovecot/dovecot.conf && \

sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" /etc/dovecot/dovecot-sql.conf.ext && \
sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" /etc/postfix/mysql-virtual-mailbox-domains.cf && \
sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" /etc/postfix/mysql-virtual-mailbox-maps.cf && \
sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" /etc/postfix/mysql-virtual-alias-maps.cf && \

sed -i -re"s/%MYSQL_IP%/$DB_IP/g" /etc/dovecot/dovecot-sql.conf.ext && \
sed -i -re"s/%MYSQL_IP%/$DB_IP/g" /etc/postfix/mysql-virtual-mailbox-domains.cf && \
sed -i -re"s/%MYSQL_IP%/$DB_IP/g" /etc/postfix/mysql-virtual-mailbox-maps.cf && \
sed -i -re"s/%MYSQL_IP%/$DB_IP/g" /etc/postfix/mysql-virtual-alias-maps.cf && \

sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" /tmp/create_mysql_db.sql && \
mysql -u $(echo $SQL_USER) -p$(echo $SQL_PASSWORD) -h $DB_IP < /tmp/create_mysql_db.sql && \

/etc/init.d/rsyslog start && \
service spamassassin start && \
service postfix restart && \
service dovecot restart && \
tail -f /var/log/mail.info
