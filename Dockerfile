FROM debian
MAINTAINER Dario Andrei <wouldgo84@gmail.com>

RUN apt-get update && apt-get upgrade -y

RUN apt-get --purge remove 'exim4*'
RUN apt-get install -y rsyslog postfix postfix-mysql swaks dovecot-mysql dovecot-pop3d dovecot-imapd dovecot-managesieved libpcre3

ADD confs/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf
ADD confs/mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf
ADD confs/mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf
ADD confs/mysql-email2email.cf /etc/postfix/mysql-email2email.cf
ADD confs/dovecot-sql.conf.ext /tmp/dovecot-sql.conf.ext

RUN postconf -e 'virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf' && postconf -e 'virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf' && postconf -e 'virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf'
RUN chgrp postfix /etc/postfix/mysql-*.cf && chmod u=rw,g=r,o= /etc/postfix/mysql-*.cf && groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /var/vmail -m && chown -R vmail:vmail /var/vmail && chmod u+w /var/vmail

RUN sed -i -re"s/\s*auth_mechanisms\s*=\s*.*/auth_mechanisms = plain login/g" /etc/dovecot/conf.d/10-auth.conf && sed -i -re"s/\s*\!include auth-system.conf.ext\s*/#\!include auth-system.conf.ext/g" /etc/dovecot/conf.d/10-auth.conf && sed -i -re"s/\s*#\!include auth-sql.conf.ext\s*/\!include auth-sql.conf.ext/g" /etc/dovecot/conf.d/10-auth.conf

RUN grep -n -A 3 -P "^((\?\!\#).)*userdb.*$" /etc/dovecot/conf.d/auth-sql.conf.ext | sed -re"s/^([0-9]+)[:|-].+/\1/g" | while read source; do sed -i -re"$(echo $source)s/^/\#/" /etc/dovecot/conf.d/auth-sql.conf.ext; done && echo "\r\nuserdb {\r\n  driver = static\r\n  args = uid=vmail gid=vmail home=/var/vmail/%d/%n\r\n}" >> /etc/dovecot/conf.d/auth-sql.conf.ext

RUN sed -i -re"s/\s*mail_location\s*=.+/mail_location = maildir:\/var\/vmail\/%d\/%n\/Maildir/g" /etc/dovecot/conf.d/10-mail.conf
RUN perl -0777 -i.original -pe 's/# Postfix smtp-auth\n.*#unix_listener \/var\/spool\/postfix\/private\/auth {\n.*#  mode = 0666\n.*#}\n/# Postfix smtp-auth\n  unix_listener \/var\/spool\/postfix\/private\/auth {\n    mode = 0660\n    user = postfix\n    group = postfix\n  }\n/igs' /etc/dovecot/conf.d/10-master.conf


RUN sed -i -e"s/  #mail_plugins = \$mail_plugins/  mail_plugins = \$mail_plugins sieve/g" /etc/dovecot/conf.d/15-lda.conf
RUN cat /tmp/dovecot-sql.conf.ext >> /etc/dovecot/dovecot-sql.conf.ext

RUN chgrp vmail /etc/dovecot/dovecot.conf && chmod g+r /etc/dovecot/dovecot.conf && chown root:root /etc/dovecot/dovecot-sql.conf.ext && chmod go= /etc/dovecot/dovecot-sql.conf.ext


RUN ln -s /proc/mounts /etc/mtab
CMD ["sh", "-c", "/etc/init.d/rsyslog start && /etc/init.d/postfix restart && /etc/init.d/dovecot restart && tail -f /var/log/mail.info" ]