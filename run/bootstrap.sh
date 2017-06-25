#!/usr/bin/env bash

echo "Starting mail container for $(hostname -A)..." \
  && postconf -e "myhostname = $(hostname -A)" \
  && echo "postmaster_address=postmaster at $(hostname -A)" >> /etc/dovecot/dovecot.conf \
  && chown -Rf vmail:mail /var/vmail

  touch /etc/opendkim/TrustedHosts \
  && touch /etc/opendkim/KeyTable \
  && touch /etc/opendkim/SigningTable

  echo "127.0.0.1" >> /etc/opendkim/TrustedHosts \
  && echo "localhost" >> /etc/opendkim/TrustedHosts \
  && echo "192.168.0.1/24" >> /etc/opendkim/TrustedHosts \
  && chown -Rf vmail:mail /opt/dkim-pub

  /etc/init.d/rsyslog start \
  && service spamassassin start \
  && service postfix start \
  && service dovecot start \
  && service opendkim start \
  && service php7.0-fpm start \
  && service nginx start \
  && tail -f /var/log/mail.log
