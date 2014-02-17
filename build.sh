#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
else

	mkdir postfix-conf
	mkdir mail-folders

	echo "Give the hostname"
	read HOSTNAME

	echo "Give the other destinations (comma separated like:
server1.example.com, anotherdomain.com)"
	read DESTINATIONS

	if [[ $DESTINATIONS -ne "" ]]; then
		DESTINATIONS=$DESTINATIONS','
	fi

	sed -i -re"s/%HOSTNAME_STRING%/$HOSTNAME/" Dockerfile
	sed -i -re"s/%DESTINATIONS_STRING%/$DESTINATIONS/" Dockerfile

	docker build -t wouldgo/mail .
fi