#!/usr/bin/env bash

regex="[\.|\*]*(.*)" && \
for i in "$@"; do
  echo "$i" >> /etc/opendkim/TrustedHosts

  [[ $i =~ $regex ]]
  DOMAIN="${BASH_REMATCH[1]}"
  echo "mail._domainkey.$DOMAIN $DOMAIN:mail:/etc/opendkim/keys/$DOMAIN/mail.private" >> /etc/opendkim/KeyTable

  echo "*@$DOMAIN mail._domainkey.$DOMAIN" >> /etc/opendkim/SigningTable

  mkdir -p "/etc/opendkim/keys/$DOMAIN"
  cd "/etc/opendkim/keys/$DOMAIN" && \
  opendkim-genkey -s mail -d $(echo $DOMAIN) && \
  chown opendkim:opendkim mail.private && \
  cat mail.txt >> /opt/dkim-pub/$DOMAIN
done
