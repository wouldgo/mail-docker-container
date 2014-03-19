FROM debian
MAINTAINER Dario Andrei <wouldgo84@gmail.com>

RUN apt-get update && apt-get upgrade -y

RUN apt-get --purge remove 'exim4*'
RUN apt-get install -y apg
RUN apt-get install -y postfix postfix-mysql swaks dovecot-mysql dovecot-pop3d dovecot-imapd dovecot-managesieved
