#!/bin/bash

MASTER_SLAVE=0
while getopts ":m" arg; do
  case $arg in
    m)
      MASTER_SLAVE=1
  esac
done
./scripts/gen_keys.sh
HASH=`openssl dgst keys/Alice.pem|cut -d' ' -f2`
if [ $MASTER_SLAVE -eq 1 ]
then
  python3 scripts/server.py
else
  ./scripts/exchange_keys.sh
fi
NEW_HASH=`openssl dgst keys/Alice.pem|cut -d' ' -f2`
if [ "$HASH" != "$NEW_HASH" ]
then
  echo "Error key was tampered with."
  exit
fi
./scripts/check_pubkey_hashes.sh
./scripts/derive_secret.sh
./scripts/get_tx_keys.sh
./scripts/cleanup.sh
