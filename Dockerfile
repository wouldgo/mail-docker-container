FROM ubuntu:16.04
LABEL maintainer "Dario Andrei <wouldgo84@gmail.com>"
ARG POSTFIXADMIN_VERSION=3.0.2
ARG POSTFIXADMIN_ADMIN_PASSWORD=super_strong_password
ENV POSTFIXADMIN_URL="http://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-${POSTFIXADMIN_VERSION}/postfixadmin-${POSTFIXADMIN_VERSION}.tar.gz"
ENV POSTFIXADMIN_VERSION_ENV="${POSTFIXADMIN_VERSION}"
ENV POSTFIXADMIN_ADMIN_PASSWORD_ENV="${POSTFIXADMIN_ADMIN_PASSWORD}"

ADD nginx/postfix-admin.conf /tmp/postfix-admin.conf

ADD run/bootstrap.sh /opt/bootstrap.sh
ADD run/opendkim.sh /opt/opendkim.sh

RUN apt-get update

RUN apt-get install -y \
  rsyslog \
  wget \
  dbconfig-common \
  sqlite3 \

  php-fpm \
  php-cli \
  php7.0-mbstring \
  php7.0-imap \
  php7.0-sqlite3 \
  nginx

RUN useradd -r -u 150 -g mail -d /var/vmail -s /sbin/nologin \
    -c "Virtual Mail User" vmail \
  && mkdir -p /var/vmail \
  && chmod -R 770 /var/vmail \
  && chown -R vmail:mail /var/vmail

RUN sed -i -re"s/postfixadmin-[$]\{POSTFIXADMIN_VERSION\}/postfixadmin-${POSTFIXADMIN_VERSION}/g" /tmp/postfix-admin.conf \
  && cp /tmp/postfix-admin.conf /etc/nginx/sites-available/postfix-admin.conf \
  && ln -s /etc/nginx/sites-available/postfix-admin.conf /etc/nginx/sites-enabled/postfix-admin.conf \
  && rm -Rfv /etc/nginx/sites-enabled/default \
  && nginx -t

RUN wget -q -O - ${POSTFIXADMIN_URL} | tar -xzf - -C /var/www \
  && echo "/var/www/postfixadmin-${POSTFIXADMIN_VERSION}/config.inc.php" \
  && sed -i -re"s/^[$]CONF\['configured'.+/\$CONF['configured'] = true;/g" /var/www/postfixadmin-${POSTFIXADMIN_VERSION}/config.inc.php \
  && sed -i -re"s/^[$]CONF\['database_type'\].+/\$CONF['database_type'] = 'sqlite';/g" /var/www/postfixadmin-${POSTFIXADMIN_VERSION}/config.inc.php \
  && sed -i -re"s/^[$]CONF\['database_name'\].+/\$CONF['database_name'] = '\/var\/vmail\/postfixadmin.db';/g" /var/www/postfixadmin-${POSTFIXADMIN_VERSION}/config.inc.php \
  && sed -i -re"s/^[$]CONF\['domain_path'\].+/\$CONF['domain_path'] = 'NO';/g" /var/www/postfixadmin-${POSTFIXADMIN_VERSION}/config.inc.php \
  && sed -i -re"s/^[$]CONF\['domain_in_mailbox'\].+/\$CONF['domain_in_mailbox'] = 'YES';/g" /var/www/postfixadmin-${POSTFIXADMIN_VERSION}/config.inc.php \

  && sed -i -re"s/^[$]CONF\['database_host'\].+$//g" /var/www/postfixadmin-${POSTFIXADMIN_VERSION}/config.inc.php \
  && sed -i -re"s/^[$]CONF\['database_user'\].*$//g" /var/www/postfixadmin-${POSTFIXADMIN_VERSION}/config.inc.php \
  && sed -i -re"s/^[$]CONF\['database_password'\].*$//g" /var/www/postfixadmin-${POSTFIXADMIN_VERSION}/config.inc.php \
  && chown -R www-data:www-data /var/www/postfixadmin-${POSTFIXADMIN_VERSION}

RUN touch /var/vmail/postfixadmin.db \
  && chmod g+w /var/vmail/postfixadmin.db \
  && chown vmail:mail /var/vmail/postfixadmin.db \
  && usermod -a -G mail www-data

RUN apt-get install -y \
  postfix
RUN echo $"dbpath = /var/vmail/postfixadmin.db\n\
query = SELECT goto FROM alias WHERE address='%s' AND active = '1'" > /etc/postfix/sqlite_virtual_alias_maps.cf \
  && echo $"dbpath = /var/vmail/postfixadmin.db\n\
query = SELECT goto FROM alias,alias_domain WHERE alias_domain.alias_domain = '%d' and alias.address = printf('%u', '@', alias_domain.target_domain) AND alias.active = 1 AND alias_domain.active='1'" > /etc/postfix/sqlite_virtual_alias_domain_maps.cf \
  && echo $"dbpath = /var/vmail/postfixadmin.db\n\
query  = SELECT goto FROM alias,alias_domain WHERE alias_domain.alias_domain = '%d' and alias.address = printf('@', alias_domain.target_domain) AND alias.active = 1 AND alias_domain.active='1'" > /etc/postfix/sqlite_virtual_alias_domain_catchall_maps.cf \
  && echo $"dbpath = /var/vmail/postfixadmin.db\n\
query = SELECT domain FROM domain WHERE domain='%s' AND active = '1'" > /etc/postfix/sqlite_virtual_domains_maps.cf \
  && echo $"dbpath = /var/vmail/postfixadmin.db\n\
query = SELECT maildir FROM mailbox WHERE username='%s' AND active = '1'" > /etc/postfix/sqlite_virtual_mailbox_maps.cf \
  && echo $"dbpath = /var/vmail/postfixadmin.db\n\
query = SELECT maildir FROM mailbox,alias_domain WHERE alias_domain.alias_domain = '%d' and mailbox.username = printf('%u', '@', alias_domain.target_domain) AND mailbox.active = 1 AND alias_domain.active='1'" > /etc/postfix/sqlite_virtual_alias_domain_mailbox_maps.cf

RUN postconf -e "virtual_mailbox_domains = sqlite:/etc/postfix/sqlite_virtual_domains_maps.cf" \
  && postconf -e "virtual_alias_maps =  sqlite:/etc/postfix/sqlite_virtual_alias_maps.cf, sqlite:/etc/postfix/sqlite_virtual_alias_domain_maps.cf, sqlite:/etc/postfix/sqlite_virtual_alias_domain_catchall_maps.cf" \
  && postconf -e "virtual_mailbox_maps = sqlite:/etc/postfix/sqlite_virtual_mailbox_maps.cf, sqlite:/etc/postfix/sqlite_virtual_alias_domain_mailbox_maps.cf" \

  && postconf -e "smtpd_tls_cert_file = /etc/ssl/certs/ssl-cert-snakeoil.pem" \
  && postconf -e "smtpd_tls_key_file = /etc/ssl/private/ssl-cert-snakeoil.key" \
  && postconf -e "smtpd_use_tls = yes" \
  && postconf -e "smtpd_tls_auth_only = yes" \

  && postconf -e "smtpd_sasl_type = dovecot" \
  && postconf -e "smtpd_sasl_path = private/auth" \
  && postconf -e "smtpd_sasl_auth_enable = yes" \
  && postconf -e "smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination" \

  && postconf -e "mydestination = localhost" \
  && postconf -e "mynetworks = 127.0.0.0/8" \
  && postconf -e "inet_protocols = ipv4" \

  && postconf -e "virtual_transport = lmtp:unix:private/dovecot-lmtp" \

  && postconf -e "compatibility_level=2"
RUN sed -i -re "s/^#submission inet n.+$/submission inet n        -       y       -       -       smtpd/g" /etc/postfix/master.cf \
  && sed -i -re "s/^#smtps\s+inet\s+n.+$/smtps      inet  n       -       y       -       -       smtpd/g" /etc/postfix/master.cf \
  && sed -i -re "s/^#(\s+-o syslog_name=postfix\/.*)$/\1/g" /etc/postfix/master.cf \
  && sed -i -re "s/^#(\s+-o smtpd_tls_security_level=encrypt.*)$/\1/g" /etc/postfix/master.cf \
  && sed -i -re "s/^#(\s+-o smtpd_sasl_auth_enable=yes.*)$/\1/g" /etc/postfix/master.cf \
  && sed -i -re "s/^#(\s+-o smtpd_client_restrictions=permit_sasl_authenticated,reject.*)$/\1/g" /etc/postfix/master.cf \
  && sed -i -re "s/^#(\s+-o milter_macro_daemon_name=ORIGINATING.*)$/\1/g" /etc/postfix/master.cf

RUN apt-get install -y \
  dovecot-imapd \
  dovecot-lmtpd \
  dovecot-pop3d \
  dovecot-sqlite
ADD dovecot/etc/dovecot/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext
ADD dovecot/etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf
RUN sed -i -re "s/^\s*mail_location\s*=.+$/mail_location = maildir:\/var\/vmail\/%d\/%n\nmail_privileged_group = mail\nmail_uid = vmail\nmail_gid = mail\nfirst_valid_uid = 150\nlast_valid_uid = 150/g" \
    /etc/dovecot/conf.d/10-mail.conf \
  && sed -i -re "s/^\s*auth_mechanisms.*/auth_mechanisms = plain login/g" \
    /etc/dovecot/conf.d/10-auth.conf \
  && sed -i -re "s/^(!include auth-system.conf.ext)$/#\1/g" \
    /etc/dovecot/conf.d/10-auth.conf \
  && sed -i -re "s/^#(!include auth-sql.conf.ext)$/\1/g" \
    /etc/dovecot/conf.d/10-auth.conf
RUN sed -i -re "s/^ssl = no$/ssl = yes/g" /etc/dovecot/conf.d/10-ssl.conf
RUN sed -i -re "s/^#postmaster_address =.*$/postmaster_address = wouldgo84@gmail.com/g" /etc/dovecot/conf.d/15-lda.conf
RUN chown -R vmail:dovecot /etc/dovecot \
  && chmod -R o-rwx /etc/dovecot

RUN apt-get install -y \
    spamassassin \
    spamc \
  && adduser spamd --disabled-login
ADD spamassassin/etc/spamassassin/local.cf /etc/spamassassin/local.cf
RUN sed -i -re "s/^ENABLED=0.*$/ENABLED=1/g" /etc/default/spamassassin \
  && sed -i -re "s/^OPTIONS=\".+$/OPTIONS=\"--create-prefs --max-children 5 -d 127.0.0.1 --username spamd --helper-home-dir \/home\/spamd\/ -s \/home\/spamd\/spamd.log\"/g" /etc/default/spamassassin \
  && sed -i -re "s/^PIDFILE=\".+$/PIDFILE=\"\/home\/spamd\/spamd.pid\"/g" /etc/default/spamassassin \
  && sed -i -re "s/^CRON=0$/CRON=1/g" /etc/default/spamassassin \
  && sed -i -re "s/^\s*smtp\s+inet\s+n.+$/smtp       inet  n       -       -       -       -       smtpd\n  -o content_filter=spamassassin/g" /etc/postfix/master.cf \
  && head -n -1 /etc/postfix/master.cf > /tmp/postfix_master.cf \
  && mv /tmp/postfix_master.cf /etc/postfix/master.cf \
  && echo "spamassassin unix  -       n       n       -       -       pipe\n\
   user=spamd argv=/usr/bin/spamc -f -e /usr/sbin/sendmail -oi -f \${sender} \${recipient}\n\
" >> /etc/postfix/master.cf

RUN apt-get install -y \
  opendkim \
  opendkim-tools
ADD opendkim/etc/opendkim.conf /etc/opendkim.conf
RUN echo 'SOCKET="inet:12301@localhost"' >> /etc/default/opendkim \
 && postconf -e "milter_protocol = 2" \
 && postconf -e "milter_default_action = accept" \
 && postconf -e "smtpd_milters = inet:localhost:12301" \
 && postconf -e "non_smtpd_milters = inet:localhost:12301" \
 && mkdir -p /etc/opendkim/keys \
 && mkdir -p /opt/dkim-pub \
 && touch /etc/opendkim/TrustedHosts \
 && touch /etc/opendkim/KeyTable \
 && touch /etc/opendkim/SigningTable \
 && echo "127.0.0.1" >> /etc/opendkim/TrustedHosts \
 && echo "localhost" >> /etc/opendkim/TrustedHosts \
 && echo "192.168.0.1/24" >> /etc/opendkim/TrustedHosts \
 && chown -Rf vmail:mail /opt/dkim-pub

RUN apt-get install -y \
  lynx

VOLUME ["/var/vmail", "/var/log", "/opt/dkim-pub"]
EXPOSE 25 587 993 80
RUN chmod u+x /opt/bootstrap.sh /opt/opendkim.sh
ENTRYPOINT ["/opt/bootstrap.sh"]
