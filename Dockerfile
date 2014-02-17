FROM wouldgo/debian
MAINTAINER Dario Andrei <wouldgo84@gmail.com>

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get -y install rsyslog dovecot-imapd dovecot-pop3d postfix

RUN postconf -e 'myhostname = %HOSTNAME_STRING%'
RUN postconf -e 'mydestination = %HOSTNAME_STRING%, %DESTINATIONS_STRING% localhost.localdomain, localhost'
RUN postconf -e 'myorigin = $mydomain'

RUN mv /usr/share/dovecot/protocols.d/pop3d.protocol /usr/share/dovecot/protocols.d/pop3d.disabledprotocol
RUN sed -i -e"s/^#mail_location\ =.*/mail_location\ =\ maildir:~\/maildir/" /etc/dovecot/conf.d/10-mail.conf

CMD ["sh", "-c", "/etc/init.d/rsyslog start ; /etc/init.d/postfix start ; tail -F /var/log/mail.info" ]
