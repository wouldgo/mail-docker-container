FROM wouldgo/debian
MAINTAINER Dario Andrei <wouldgo84@gmail.com>

RUN apt-get update
RUN apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install dovecot-imapd dovecot-pop3d postfix

RUN mv /usr/share/dovecot/protocols.d/pop3d.protocol /usr/share/dovecot/protocols.d/pop3d.disabledprotocol
RUN sed -i -e"s/^#mail_location\ =.*/mail_location\ =\ maildir:~\/maildir/" /etc/dovecot/conf.d/10-mail.conf
