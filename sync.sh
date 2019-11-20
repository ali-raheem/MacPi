#!/bin/bash

MASTER_SLAVE=0
while getopts ":m" arg; do
  case $arg in
    m)
      MASTER_SLAVE=1
  esac
done

openssl genpkey -paramfile keys/params.pem -out keys/Alice.pem 2>/dev/null
openssl ec -in keys/Alice.pem -pubout -out keys/Alice.pub.pem 2>/dev/null

HASH=`openssl dgst keys/Alice.pem|cut -d' ' -f2`
if [ $MASTER_SLAVE -eq 1 ]
then
  python3 scripts/server.py
else
  PUBKEY=`cat keys/Alice.pub.pem|base64`
  wget -X POST --post-data "pubkey=$PUBKEY" http://127.0.0.1:5000/public_key -O keys/Bob.pub.pem

fi
NEW_HASH=`openssl dgst keys/Alice.pem|cut -d' ' -f2`
if [ "$HASH" != "$NEW_HASH" ]
then
  echo "Error key was tampered with."
  exit -1
fi

if [ -f keys/Bob.pub.pem.b64 ]
then
  cat keys/Bob.pub.pem.b64 | base64 -d > keys/Bob.pub.pem
  rm keys/Bob.pub.pem.b64
fi

ALICE_HASH=`openssl ec -pubout -pubin -inform PEM -in keys/Alice.pub.pem -outform der 2>/dev/null|sha256sum|cut -d' ' -f1`
BOB_HASH=`openssl ec -pubout -pubin -inform PEM -in keys/Bob.pub.pem -outform der 2>/dev/null|sha256sum|cut -d' ' -f1`

if [ $MASTER_SLAVE -eq 1 ]
then
  echo $ALICE_HASH
  echo $BOB_HASH
else
  echo $BOB_HASH
  echo $ALICE_HASH
fi

if [ -f keys/shared_secret.bin ]
then
  rm keys/shared_secret.bin
fi

openssl pkeyutl -derive -inkey keys/Alice.pem -peerkey keys/Bob.pub.pem -out keys/shared_secret.bin

if [ ! -f keys/shared_secret.bin ]
then
  echo "Failed to derive shared secret."
  exit -1
fi

KEY=`openssl dgst keys/shared_secret.bin|cut -d' ' -f2`
MASTER_TX_KEY=${KEY:0:32}
SLAVE_TX_KEY=${KEY:32:64}

echo $MASTER_TX_KEY
echo $SLAVE_TX_KEY

# Setup macsec $BOB_MAC $MASTER_TX_KEY $SLAVE_TX_KEY

rm keys/Alice.* keys/Bob.* keys/shared_secret.bin

