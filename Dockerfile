FROM wouldgo/debian
MAINTAINER Dario Andrei <wouldgo84@gmail.com>

RUN apt-get update
RUN apt-get upgrade -y

RUN groupadd -g 9874 mail-user
RUN useradd -m -u 9874 -g 9874 -s /bin/bash mail-user

RUN apt-get -y install rsyslog dovecot-common dovecot-imapd dovecot-pop3d postfix libsasl2-2 sasl2-bin libsasl2-modules

RUN mkdir -p /opt/conf
RUN mkdir -p /opt/mails/%HOSTNAME_STRING%

RUN touch /opt/conf/vhosts
RUN touch /opt/conf/vmaps
RUN touch /opt/conf/virtual

RUN echo '%HOSTNAME_STRING%' >> /opt/conf/vhosts
RUN echo 'info@%HOSTNAME_STRING%  %HOSTNAME_STRING%/info/' >> /opt/conf/vmaps
RUN postmap /opt/conf/vmaps

RUN echo 'postmaster@%HOSTNAME_STRING%  postmaster' >> /opt/conf/virtual
RUN postmap /opt/conf/virtual

RUN chown -Rfv mail-user:mail-user /opt
RUN chmod -Rfv g+rwx /opt/mails

RUN postconf -e 'virtual_mailbox_domains = /opt/conf/vhosts'
RUN postconf -e 'virtual_mailbox_base = /opt/mails'
RUN postconf -e 'virtual_mailbox_maps = hash:/opt/conf/vmaps'
RUN postconf -e 'virtual_alias_maps = hash:/opt/conf/virtual'
RUN postconf -e 'virtual_minimum_uid = 1000'
RUN postconf -e 'virtual_uid_maps = static:9874'
RUN postconf -e 'virtual_gid_maps = static:9874'

RUN postconf -e 'alias_database = hash:/opt/confs/aliases'
RUN postconf -e 'alias_maps = hash:/opt/confs/aliases'

RUN postconf -e 'myhostname = localhost'
RUN postconf -e 'myorigin = $myhostname'
RUN postconf -e 'mydestination = '
RUN postconf -e 'home_mailbox = Maildir/'
RUN postconf -e 'mailbox_command ='

RUN postconf -e 'smtpd_sasl_local_domain ='
RUN postconf -e 'smtpd_sasl_auth_enable = yes'
RUN postconf -e 'smtpd_sasl_security_options = noanonymous'
RUN postconf -e 'broken_sasl_auth_clients = yes'
RUN postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'
RUN postconf -e 'inet_interfaces = all'

RUN echo 'pwcheck_method: saslauthd' >> /etc/postfix/sasl/smtpd.conf
RUN echo 'mech_list: plain login' >> /etc/postfix/sasl/smtpd.conf

RUN cd /etc/postfix/sasl
RUN touch smtpd.key
RUN chmod 600 smtpd.key
RUN openssl genrsa 1024 > smtpd.key
RUN openssl req -new -key smtpd.key -x509 -days 3650 -out smtpd.crt -subj "/C=%STATE_STRING%/ST=%PROVINCE_STRING%/L=%CITY_STRING%/O=%ORG_STRING%/CN=%HOSTNAME_STRING%/emailAddress=info@%HOSTNAME_STRING%"
RUN openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 3650 -nodes -subj "/C=%STATE_STRING%/ST=%PROVINCE_STRING%/L=%CITY_STRING%/O=%ORG_STRING%/CN=%HOSTNAME_STRING%/emailAddress=info@%HOSTNAME_STRING%"
RUN mv smtpd.key /etc/ssl/private/
RUN mv smtpd.crt /etc/ssl/certs/
RUN mv cakey.pem /etc/ssl/private/
RUN mv cacert.pem /etc/ssl/certs/

RUN postconf -e 'smtp_tls_security_level = may'
RUN postconf -e 'smtpd_tls_security_level = may'
RUN postconf -e 'smtpd_tls_auth_only = no'
RUN postconf -e 'smtp_tls_note_starttls_offer = yes'
RUN postconf -e 'smtpd_tls_key_file = /etc/ssl/private/smtpd.key'
RUN postconf -e 'smtpd_tls_cert_file = /etc/ssl/certs/smtpd.crt'
RUN postconf -e 'smtpd_tls_CAfile = /etc/ssl/certs/cacert.pem'
RUN postconf -e 'smtpd_tls_loglevel = 1'
RUN postconf -e 'smtpd_tls_received_header = yes'
RUN postconf -e 'smtpd_tls_session_cache_timeout = 3600s'
RUN postconf -e 'tls_random_source = dev:/dev/urandom'

RUN sed -i -re"s/START\s*=\s*no/START=yes/g" /etc/default/saslauthd
RUN sed -i -re"s/^.*PWDIR.*$//g" /etc/default/saslauthd
RUN sed -i -re"s/^.*PARAMS.*$//g" /etc/default/saslauthd
RUN sed -i -re"s/^.*PIDFILE.*$//g" /etc/default/saslauthd

RUN echo 'PWDIR="/var/spool/postfix/var/run/saslauthd"'
RUN echo 'PARAMS="-m ${PWDIR}"'
RUN echo 'PIDFILE="${PWDIR}/saslauthd.pid"'
RUN echo 'OPTIONS="-c -m /var/spool/postfix/var/run/saslauthd"'
RUN dpkg-statoverride --force --update --add root sasl 755 /var/spool/postfix/var/run/saslauthd

RUN mv /usr/share/dovecot/protocols.d/pop3d.protocol /usr/share/dovecot/protocols.d/pop3d.disabledprotocol
RUN sed -i -e"s/^#mail_location\ =.*/mail_location\ =\ maildir:\/opt\/mails\/%d\/%n/g" /etc/dovecot/conf.d/10-mail.conf

RUN sed -i -re"s/(^\s*)#port\s*=\s*143.*$/\1port = 143/g" /etc/dovecot/conf.d/10-master.conf
RUN sed -i -re"s/(^\s*)#port\s*=\s*993.*$/\1port = 993/g" /etc/dovecot/conf.d/10-master.conf
RUN sed -i -re"s/^.*#ssl\s*=\s*yes.*$/ssl = yes/g" /etc/dovecot/conf.d/10-master.conf
RUN sed -i -re"s/^.*ssl_cert\s*=.*/ssl_cert = \/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/g" /etc/dovecot/conf.d/10-ssl.conf
RUN sed -i -re"s/^.*ssl_key\s*=.*/ssl_key = \/etc\/ssl\/private\/ssl-cert-snakeoil.key/g" /etc/dovecot/conf.d/10-ssl.conf

RUN ln -s /proc/mounts /etc/mtab

EXPOSE 25 143
VOLUME ["/opt/conf", "/opt/mails"]

CMD ["sh", "-c", "/etc/init.d/rsyslog start && /etc/init.d/saslauthd start && /etc/init.d/postfix start && /etc/init.d/dovecot start && tail -f /var/log/mail.info" ]
