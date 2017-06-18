#!/bin/bash

postconf -e "myhostname = $(hostname -A)"























MAILUSER_PSW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)

echo "Starting mail container for $HOSTNAME using database at $DB_PORT_3306_TCP_ADDR managing $MAIL_HOSTNAMES ..."

sed -i -re"s/^myhostname.*/myhostname = $HOSTNAME/g" /etc/postfix/main.cf && \
echo "postmaster_address=postmaster at $HOSTNAME" >> /etc/dovecot/dovecot.conf && \

sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" /etc/dovecot/dovecot-sql.conf.ext && \
sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" /etc/postfix/mysql-virtual-mailbox-domains.cf && \
sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" /etc/postfix/mysql-virtual-mailbox-maps.cf && \
sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" /etc/postfix/mysql-virtual-alias-maps.cf && \

sed -i -re"s/%MYSQL_IP%/$DB_PORT_3306_TCP_ADDR/g" /etc/dovecot/dovecot-sql.conf.ext && \
sed -i -re"s/%MYSQL_IP%/$DB_PORT_3306_TCP_ADDR/g" /etc/postfix/mysql-virtual-mailbox-domains.cf && \
sed -i -re"s/%MYSQL_IP%/$DB_PORT_3306_TCP_ADDR/g" /etc/postfix/mysql-virtual-mailbox-maps.cf && \
sed -i -re"s/%MYSQL_IP%/$DB_PORT_3306_TCP_ADDR/g" /etc/postfix/mysql-virtual-alias-maps.cf && \

sed -i -re"s/%MAILUSER_PSW%/$MAILUSER_PSW/g" /tmp/create_mysql_db.sql && \
mysql -u root -p$(echo $PASSWORD) -h $DB_PORT_3306_TCP_ADDR < /tmp/create_mysql_db.sql && \

touch /etc/opendkim/TrustedHosts && \
touch /etc/opendkim/KeyTable && \
touch /etc/opendkim/SigningTable && \

echo "127.0.0.1" >> /etc/opendkim/TrustedHosts && \
echo "localhost" >> /etc/opendkim/TrustedHosts && \
echo "192.168.0.1/24" >> /etc/opendkim/TrustedHosts && \

/opt/opendkim.sh $MAIL_HOSTNAMES && \

chown -Rf vmail:vmail /opt/dkim-pub && \

/etc/init.d/rsyslog start && \
service spamassassin start && \
service postfix restart && \
service dovecot restart && \
service opendkim restart && \
tail -f /var/log/mail.info
