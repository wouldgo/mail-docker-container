#!/usr/bin/env bash

echo "Starting mail container for $(hostname -A)..." \
  && postconf -e "myhostname = $(hostname -A)" \
  && echo "postmaster_address=postmaster at $(hostname -A)" >> /etc/dovecot/dovecot.conf

service rsyslog start \
  && service spamassassin start \
  && service postfix start \
  && service dovecot start \
  && service opendkim start \
  && service php7.0-fpm start \
  && service nginx start

lynx -dump localhost:80/setup.php \
  && bash /var/www/postfixadmin-${POSTFIXADMIN_VERSION_ENV}/scripts/postfixadmin-cli \
    admin add postmaster@$(hostname -A) \
    --password ${POSTFIXADMIN_ADMIN_PASSWORD_ENV} \
    --password2 ${POSTFIXADMIN_ADMIN_PASSWORD_ENV} \
    --superadmin 1 --active 1 \
  && tail -f /var/log/mail.log
