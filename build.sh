#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Build script expect 1 params:
- <POSTFIXADMIN_VERSION> | 3.0.2 or greater
"
  exit 1;
fi

docker build \
--build-arg POSTFIXADMIN_VERSION=$1 \
--tag wouldgo/mail \
--force-rm \
.
