FROM debian
MAINTAINER Dario Andrei <wouldgo84@gmail.com>

RUN apt-get update && apt-get upgrade -y

RUN apt-get --purge remove 'exim4*'
RUN apt-get install -y apg
RUN apt-get install -y postfix postfix-mysql swaks dovecot-mysql dovecot-pop3d dovecot-imapd dovecot-managesieved

ADD confs/mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf
RUN postconf -e 'virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf'

ADD confs/mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf
RUN postconf -e 'virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf'

ADD confs/mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf
ADD confs/mysql-email2email.cf /etc/postfix/mysql-email2email.cf
RUN postconf -e 'virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf'

RUN chgrp postfix /etc/postfix/mysql-*.cf && chmod u=rw,g=r,o= /etc/postfix/mysql-*.cf
