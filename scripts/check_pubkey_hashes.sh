#!/bin/bash

if [ -f keys/Bob.pub.pem.b64 ]
then
  cat keys/Bob.pub.pem.b64 | base64 -d > keys/Bob.pub.pem
  rm keys/Bob.pub.pem.b64
fi

MASTER_HASH=`openssl ec -pubout -pubin -inform PEM -in keys/Alice.pub.pem -outform der 2>/dev/null| sha256sum|cut -d' ' -f1`
SLAVE_HASH=`openssl ec -pubout -pubin -inform PEM -in keys/Bob.pub.pem -outform der 2>/dev/null| sha256sum|cut -d' ' -f1`

echo $MASTER_HASH
echo $SLAVE_HASH
