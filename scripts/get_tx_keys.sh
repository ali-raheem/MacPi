#!/bin/bash

KEY=`openssl dgst keys/shared_secret.bin|cut -d' ' -f2`
MASTER_TX_KEY=${KEY:0:32}
SLAVE_TX_KEY=${KEY:32:64}

echo $MASTER_TX_KEY
echo $SLAVE_TX_KEY
