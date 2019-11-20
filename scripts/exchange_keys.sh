#!/bin/bash

PUBKEY=`cat keys/Alice.pub.pem|base64`
wget -X POST --post-data "pubkey=$PUBKEY" http://127.0.0.1:5000/public_key -O keys/Bob.pub.pem
